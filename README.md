# ImGui.NET Native Build

Build scripts and packaging metadata for the native libraries used by ImGui.NET and UImGui.

This repository builds platform-specific native binaries (`.dll`, `.so`, and `.dylib`) for `cimgui`, `cimplot`, `cimplot3d`, `cimnodes`, `cimnodes_r`, `cimguizmo`, `cimguizmo_quat`, and `cimCTE`. It also produces the `ImGui.NET.SourceBuild` NuGet package, which bundles the `cimgui` and Dear ImGui C/C++ sources for projects that need to compile them directly, such as WebAssembly/Emscripten targets.

This project is also used to simplify and support the migration of [`ImGui.NET.4Unity`](https://github.com/psydack/ImGui.NET.4Unity).

Current version: `1.92.9`

## External Project Versions

Current submodule references used by this repository:

| Project | Version/Ref |
| --- | --- |
| `cimgui` | `b5f5e21` + Dear ImGui `b334d19` (`1.92.9`, docking) |
| `cimplot` | `da10052` + ImPlot `1351ab2` |
| `cimplot3d` | `2da5c19` + ImPlot3D `6cbefa9` |
| `cimnodes` | `ba3cd2e` + imnodes `c9bb8e9` |
| `cimnodes_r` | `d7773e8` |
| `cimguizmo` | `b5f40d7` + ImGuizmo `dc25afb` |
| `cimguizmo_quat` | `03658b0` + imGuIZMO.quat `da1a5b0` |
| `cimCTE` | `84be9ba` + compatible ImGuiColorTextEdit `e83caa8` |

## Repository Layout

- `<library>/`: Git submodules for each generated C wrapper.
- `cmake/`: injected CMake configurations shared by local and CI builds.
- `build-native.cmd`: Windows native build script.
- `build-native.sh`: Linux and macOS native build script.
- `ci-build.cmd` and `ci-build.sh`: build all eight libraries.
- `scripts/check-exports.sh`: verifies required native exports.
- `tests/ImGuiNativeTests/`: functional native-loader tests.
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
git submodule update --init --recursive
```

To update the wrapper forks to their configured branches:

```bash
git submodule update --remote --recursive
```

## Build Native Library

### Windows

```cmd
build-native.cmd [Debug|Release] [x64|x86|ARM64|ARM] [--lib <library>]
```

Examples:

```cmd
build-native.cmd Release x64
build-native.cmd Debug ARM64
build-native.cmd Release x64 --lib cimplot
```

Build all eight libraries:

```cmd
ci-build.cmd Release x64
ci-build.cmd Release x86
```

Windows binaries are written under:

```text
<library>/build/<ARCH>/<CONFIG>/
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

Linux and macOS binaries are written under:

```text
<library>/build/<CONFIG>/
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

## Windows binary hardening

Release DLLs use:

- static MSVC runtime linkage (`/MT`)
- Address Space Layout Randomization (`/DYNAMICBASE`)
- Data Execution Prevention (`/NXCOMPAT`)
- Control Flow Guard (`/guard:cf`)
- reproducible linking (`/Brepro`)
- PE product and file-version metadata sourced from `version.json`

The final DLLs must not import `VCRUNTIME`, `MSVCP`, or `ucrtbase`.

## Updating the native stack

1. Update and regenerate the individual wrapper forks.
2. Push wrapper commits before updating this repository's gitlinks.
3. Update every affected submodule pointer and `version.json`.
4. Build Windows x64 and x86 locally.
5. Run export checks, functional tests, PE dependency checks, and an antivirus scan.
6. Push `main` and wait for the Windows ARM64, Linux x64, and macOS universal CI jobs.
7. Consume the exact CI artifacts in `ImGui.NET.4Unity`; never mix artifacts from different native revisions.

Review the complete nested state before committing:

```bash
git status
git diff
git submodule status --recursive
```

## Releasing

Releases are triggered by annotated version tags.

```bash
git tag -a 1.92.9 -m "Release 1.92.9"
git push origin 1.92.9
```

Tags matching `N.N.N` or `vN.N.N` are treated as public releases by `version.json`.

## CI

GitHub Actions builds all eight libraries for:

- Ubuntu x64
- macOS universal (`arm64` + `x86_64`)
- Windows x64, x86, and ARM64

The Windows x64 job also verifies exports, runs functional tests, and builds the NuGet source package.
