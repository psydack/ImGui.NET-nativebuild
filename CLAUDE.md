# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo builds the native `cimgui` shared library (`.dll`/`.so`/`.dylib`) used by ImGui.NET. It also produces a NuGet source package (`ImGui.NET.SourceBuild`) bundling cimgui C/C++ sources for WASM/Emscripten consumers. The `cimgui` directory is a git submodule tracking the `docking_inter` branch of https://github.com/cimgui/cimgui.

## Build Commands

**Windows (builds `cimgui/build/<ARCH>/<CONFIG>/cimgui.dll`):**
```cmd
build-native.cmd [Release|Debug] [x64|x86|ARM64|ARM]
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
3. Commit and push to main (triggers CI).
4. To cut a release: `git tag -a 1.XX.Y -m "..."` then `git push origin 1.XX.Y` — tags matching `N.N.N` or `vN.N.N` trigger a GitHub release with all platform binaries.

**Preferred: use the `Manual Release` workflow** from the GitHub Actions tab. It takes a version in `N.N.N` format (no `v` prefix), updates the submodule, verifies `IMGUI_VERSION` in `cimgui/imgui/imgui.h`, bumps `version.json`, creates an `update/<version>` branch, builds all artifacts, tags, and publishes the release automatically.

## CI Matrix

GitHub Actions (`build.yml`) builds on:
- `ubuntu-latest` — produces `cimgui.so`
- `macos-latest` — produces `cimgui.dylib` (fat binary: arm64 + x86_64)
- `windows-latest` × `x64`, `x86`, `ARM64` — produces `cimgui.dll` per arch

The NuGet package is only built/published from the `windows-latest / x64` job. Untagged pushes to master publish to MyGet; tagged pushes publish to NuGet.org.

## Versioning

Version is managed by Nerdbank.GitVersioning via `version.json`. The `publicReleaseRefSpec` triggers a public release for tags matching `N.N.N` or `vN.N.N`.
