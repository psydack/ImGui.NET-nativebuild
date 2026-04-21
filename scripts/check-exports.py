#!/usr/bin/env python3
"""Verify required symbols are exported from the cimgui native library.

Usage:
  python3 scripts/check-exports.py [--freetype] <path-to-lib>

  --freetype   Also check FreeType-specific symbols (enabled on Windows/Linux,
               skipped on macOS fat binaries where FreeType is disabled).
"""
import ctypes
import os
import sys

REQUIRED_CORE = [
    "igCreateContext",
    "igDestroyContext",
    "igNewFrame",
    "ImFontAtlas_AddFontDefault",
    "cimgui_set_assert_handler",
    "cimgui_trigger_test_assert",
]

REQUIRED_FREETYPE = [
    "ImGuiFreeType_GetFontLoader",
]


def main():
    args = sys.argv[1:]
    check_freetype = "--freetype" in args
    paths = [a for a in args if not a.startswith("--")]

    if len(paths) != 1:
        print(f"Usage: {sys.argv[0]} [--freetype] <path-to-lib>", file=sys.stderr)
        sys.exit(1)

    lib_path = paths[0]
    if not os.path.exists(lib_path):
        print(f"ERROR: Library not found: {lib_path}", file=sys.stderr)
        sys.exit(1)

    try:
        lib = ctypes.CDLL(lib_path)
    except OSError as e:
        print(f"ERROR: Failed to load library '{lib_path}': {e}", file=sys.stderr)
        sys.exit(1)

    symbols = REQUIRED_CORE + (REQUIRED_FREETYPE if check_freetype else [])
    missing = []
    for sym in symbols:
        try:
            getattr(lib, sym)
        except AttributeError:
            missing.append(sym)

    if missing:
        print(f"ERROR: Missing exported symbols in {os.path.basename(lib_path)}:", file=sys.stderr)
        for s in missing:
            print(f"  - {s}", file=sys.stderr)
        sys.exit(1)

    tag = f" (+{len(REQUIRED_FREETYPE)} FreeType)" if check_freetype else ""
    print(f"OK: {len(symbols)} symbols verified{tag} in {os.path.basename(lib_path)}")


if __name__ == "__main__":
    main()
