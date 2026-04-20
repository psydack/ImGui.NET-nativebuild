#!/usr/bin/env bash
set -euo pipefail

scriptPath="`dirname \"$0\"`"

_CMakeBuildType=Debug
_CMakeOsxArchitectures=
_Lib=cimgui

while :; do
    if [ $# -le 0 ]; then
        break
    fi

    lowerI="$(echo $1 | awk '{print tolower($0)}')"
    case $lowerI in
        debug|-debug)
            _CMakeBuildType=Debug
            ;;
        release|-release)
            _CMakeBuildType=Release
            ;;
        -osx-architectures)
            _CMakeOsxArchitectures=$2
            shift
            ;;
        --lib)
            _Lib=$2
            shift
            ;;
        *)
            __UnprocessedBuildArgs="$__UnprocessedBuildArgs $1"
    esac

    shift
done

libPath=$scriptPath/$_Lib

# Inject override CMakeLists.txt if the lib doesn't have its own
overrideCmake=$scriptPath/cmake/$_Lib/CMakeLists.txt
if [ -f "$overrideCmake" ]; then
    cp "$overrideCmake" "$libPath/CMakeLists.txt"
fi

patchFile="$scriptPath/patches/${_LibName}.patch"
if [ -f "$patchFile" ] && git -C "$libPath" apply --check "$patchFile" >/dev/null 2>&1; then
    git -C "$libPath" apply "$patchFile"
fi

mkdir -p "$libPath/build/$_CMakeBuildType"
pushd "$libPath/build/$_CMakeBuildType"
cmake ../.. -DCMAKE_OSX_ARCHITECTURES="$_CMakeOsxArchitectures" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 -DCMAKE_BUILD_TYPE=$_CMakeBuildType
make
popd
