#!/usr/bin/env bash
# Verify required symbols are exported from the cimgui native library.
# Usage: ./scripts/check-exports.sh [--freetype] <path-to-lib>
#   --freetype  Also check FreeType symbols (omit on macOS fat binary builds).
set -euo pipefail

LIB=""
CHECK_FREETYPE=false
for arg in "$@"; do
    case "$arg" in
        --freetype) CHECK_FREETYPE=true ;;
        *) LIB="$arg" ;;
    esac
done

if [ -z "$LIB" ]; then
    echo "Usage: $0 [--freetype] <path-to-lib>" >&2
    exit 1
fi

if [ ! -f "$LIB" ]; then
    echo "ERROR: Library not found: $LIB" >&2
    exit 1
fi

REQUIRED_CORE=(
    "igCreateContext"
    "igDestroyContext"
    "igNewFrame"
    "ImFontAtlas_AddFontDefault"
    "cimgui_set_assert_handler"
    "cimgui_trigger_test_assert"
)

REQUIRED_FREETYPE=(
    "ImGuiFreeType_GetFontLoader"
)

# Resolve symbol table based on platform
case "$(uname -s)" in
    Darwin)
        EXPORTS=$(nm -gU "$LIB" 2>/dev/null || true) ;;
    Linux)
        EXPORTS=$(nm -D "$LIB" 2>/dev/null || true) ;;
    MINGW*|MSYS*|CYGWIN*)
        if command -v powershell.exe >/dev/null 2>&1; then
            WIN_LIB=$(cygpath -w "$LIB" 2>/dev/null || printf '%s' "$LIB")
            EXPORTS=$(WIN_LIB="$WIN_LIB" powershell.exe -NoProfile -Command '
                $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
                if (Test-Path $vswhere) {
                    $dumpbin = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find "VC\Tools\MSVC\**\bin\Hostx64\x64\dumpbin.exe" | Select-Object -First 1
                    if ($dumpbin) { & $dumpbin /exports $env:WIN_LIB }
                }
            ' 2>/dev/null || true)
        fi
        if [ -z "$EXPORTS" ] && command -v objdump >/dev/null 2>&1; then
            EXPORTS=$(objdump -p "$LIB" 2>/dev/null || true)
        fi
        if [ -z "$EXPORTS" ]; then
            EXPORTS=$(nm "$LIB" 2>/dev/null || true)
        fi ;;
    *)
        EXPORTS=$(nm "$LIB" 2>/dev/null || true) ;;
esac

SYMBOLS=("${REQUIRED_CORE[@]}")
$CHECK_FREETYPE && SYMBOLS+=("${REQUIRED_FREETYPE[@]}")

MISSING=()
for sym in "${SYMBOLS[@]}"; do
    # Avoid grep+here-string under pipefail, which can report SIGPIPE as failure
    # even when the symbol exists.
    [[ "$EXPORTS" == *"$sym"* ]] || MISSING+=("$sym")
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "ERROR: Missing exported symbols in $(basename "$LIB"):" >&2
    printf "  - %s\n" "${MISSING[@]}" >&2
    exit 1
fi

echo "OK: ${#SYMBOLS[@]} symbols verified in $(basename "$LIB")"
