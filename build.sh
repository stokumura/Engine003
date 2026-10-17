#!/usr/bin/env bash
set -euo pipefail

BUILD_TYPE="${BUILD_TYPE:-Release}"         # debug or release build
LOCAL_SRC="/local-src"                      # workspace where the source is mounted
WORK_DIR="/workspace"                       # workspace where the build will take place
OUTPUT_DIR="/output"                        # output binaries directory

# Preset
if [[ "${BUILD_TYPE}" == "Debug" ]]; then
    PRESET="linux-debug"
else
    PRESET="linux-release"
fi
echo "Preset selected: ${PRESET}"

# Check if local source code is mounted
if [[ ! -d "${LOCAL_SRC}" ]]; then
    echo "Source code was not found or was not mounted at: ${LOCAL_SRC}" >&2
    exit 1
fi
echo "Source code mounted at ${LOCAL_SRC}"

rsync -a --delete --exclude 'build/' "${LOCAL_SRC}/" "${WORK_DIR}/"
cd "${WORK_DIR}"
rm -rf ./build
echo "Source Code prepared to build"

# Configure
cmake --preset "${PRESET}"
echo "Configuration of build completed"

cmake --build --preset "${PRESET}" -j"$(nproc)"
echo "Compilation completed"

#Copying binaries to output
BUILD_DIR_NAME="build/${PRESET}"
if [[ ! -d "${BUILD_DIR_NAME}" ]]; then
    BUILD_DIR_NAME="build"
fi

if [[ -d "${OUTPUT_DIR}" ]]; then
    DEST="${OUTPUT_DIR}/Engine002-${PRESET}"
    echo "Copying ${BUILD_DIR_NAME} to ${DEST}"
    rm -rf "${DEST}"
    cp -r "${BUILD_DIR_NAME}" "${DEST}"
    echo "Binaries copied to output directory ${OUTPUT_DIR}"
else
    echo "${OUTPUT_DIR} does not correspond to a mounted directory"
fi
