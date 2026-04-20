# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo builds the native `cimgui` shared library (`.dll`/`.so`/`.dylib`) used by ImGui.NET. It also produces a NuGet source package (`ImGui.NET.SourceBuild`) bundling cimgui C/C++ sources for WASM/Emscripten consumers. The `cimgui` directory is a git submodule tracking the `docking_inter` branch of https://github.com/cimgui/cimgui.

## Build Commands

**Windows (builds `cimgui/build/<ARCH>/<CONFIG>/cimgui.dll`):**
```cmd
build-native.cmd [Release|Debug] [x64|x86|ARM64]
```

**Linux/macOS (builds `cimgui/build/<CONFIG>/cimgui.so` or `.dylib`):**
```bash
./build-native.sh [Release|Debug]
# macOS CI also passes: -osx-architectures 'arm64;x86_64'
```

**NuGet source package (Windows only, outputs to `bin/Packages/Release/`):**
```bash
dotnet pack -c Release ImGui.NET.SourceBuild.csproj
```

## Updating cimgui / Releasing

1. `git submodule update --init` then `git submodule update --remote` to pull the latest cimgui.
2. Update `version.json` with the new version string (format: `1.XX.Y`).
3. Commit and push to master (triggers CI).
4. To cut a release: `git tag -a vN.N -m "..."` then `git push origin vN.N` — the CI workflow creates a GitHub release with all platform binaries automatically.

## CI Matrix

GitHub Actions (`build.yml`) builds on:
- `ubuntu-latest` — produces `cimgui.so`
- `macos-latest` — produces `cimgui.dylib` (fat binary: arm64 + x86_64)
- `windows-latest` × `x64`, `x86`, `ARM64` — produces `cimgui.dll` per arch

The NuGet package is only built/published from the `windows-latest / x64` job. Untagged pushes to master publish to MyGet; tagged pushes publish to NuGet.org.

## Versioning

Version is managed by Nerdbank.GitVersioning via `version.json`. The `publicReleaseRefSpec` triggers a public release for tags matching `vN.N`.
