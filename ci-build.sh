#!/usr/bin/env bash

scriptPath="`dirname \"$0\"`"
RTYPE="${1}"

LIBS="cimgui cimplot cimplot3d cimnodes cimnodes_r cimguizmo cimguizmo_quat cimCTE"

for lib in $LIBS; do
    echo "=== Building $lib ==="
    if [[ "$OSTYPE" == "darwin"* ]]; then
        $scriptPath/build-native.sh ${RTYPE} --lib $lib -osx-architectures 'arm64;x86_64'
    else
        $scriptPath/build-native.sh ${RTYPE} --lib $lib
    fi
done
