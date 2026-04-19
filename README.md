# ImGui.NET Native Build

Build scripts and packaging metadata for the native `cimgui` library used by ImGui.NET.

This repository builds platform-specific native binaries (`.dll`, `.so`, and `.dylib`) from the `cimgui` submodule. It also produces the `ImGui.NET.SourceBuild` NuGet package, which bundles the `cimgui` and dear imgui C/C++ sources for projects that need to compile them directly, such as WebAssembly/Emscripten targets.

Current version: `1.92.7`

## Repository Layout

- `cimgui/`: Git submodule for `cimgui`, tracking the `docking_inter` branch.
- `build-native.cmd`: Windows native build script.
- `build-native.sh`: Linux and macOS native build script.
- `ci-build.cmd` and `ci-build.sh`: CI wrappers around the native build scripts.
- `ImGui.NET.SourceBuild.csproj`: NuGet source package project.
- `version.json`: Repository version managed by Nerdbank.GitVersioning.

## Prerequisites

- Git with submodule support.
- CMake.
- A native C/C++ toolchain for the target platform.
- .NET SDK for packing `ImGui.NET.SourceBuild`.

On Windows, run the build from an environment where the Visual Studio C++ toolchain is available.

## Initialize Submodules

Run this once after cloning the repository:

```bash
git submodule update --init
```

To update the `cimgui` submodule to the configured upstream branch:

```bash
git submodule update --remote
```

## Build Native Library

### Windows

```cmd
build-native.cmd [Debug|Release] [x64|x86|ARM64|ARM]
```

Examples:

```cmd
build-native.cmd Release x64
build-native.cmd Debug ARM64
```

The Windows build outputs binaries under:

```text
cimgui/build/<ARCH>/<CONFIG>/
```

### Linux and macOS

```bash
./build-native.sh [Debug|Release]
```

Examples:

```bash
./build-native.sh Release
./build-native.sh Debug
```

The Linux and macOS build outputs binaries under:

```text
cimgui/build/<CONFIG>/
```

For macOS CI, the wrapper builds a universal binary using:

```bash
./build-native.sh Release -osx-architectures 'arm64;x86_64'
```

## Build NuGet Source Package

The source package bundles the `cimgui` and dear imgui source files for consumers that compile the native code as part of their own build.

```bash
dotnet pack -c Release ImGui.NET.SourceBuild.csproj
```

Package output is written under:

```text
bin/Packages/Release/
```

## Updating cimgui

1. Initialize the submodule if needed:

   ```bash
   git submodule update --init
   ```

2. Update `cimgui` to the configured upstream branch:

   ```bash
   git submodule update --remote
   ```

3. Update the package version in `version.json`.

4. Review the changes:

   ```bash
   git status
   git diff
   ```

5. Commit and push the update:

   ```bash
   git add README.md version.json cimgui
   git commit -m "Update cimgui to <version>"
   git push
   ```

## Releasing

Releases are triggered by annotated tags.

```bash
git tag -a v1.92.7 -m "Release 1.92.7"
git push origin v1.92.7
```

Tags matching `vN.N` are treated as public releases by `version.json`.

## Manual Release Workflow

Use the `Manual Release` workflow from the GitHub Actions tab to update and release a new version.

The workflow requires a version in `N.N.N` format, without the `v` prefix. The requested version must be greater than the version currently stored in `version.json`.

When it runs, the workflow:

1. Updates the `cimgui` submodule from the configured upstream branch.
2. Verifies that `cimgui/imgui/imgui.h` reports the requested `IMGUI_VERSION`.
3. Updates `version.json` and the current version line in this README.
4. Creates and pushes an `update/<version>` branch.
5. Builds all CI artifacts from that branch.
6. Creates and pushes the `v<version>` tag.
7. Creates a GitHub release named `v<version>` with versioned artifact names.

## CI

GitHub Actions builds the native library for:

- Ubuntu: `cimgui.so`
- macOS: `cimgui.dylib`
- Windows x64, x86, and ARM64: `cimgui.dll`

The NuGet source package is built from the Windows x64 job.
