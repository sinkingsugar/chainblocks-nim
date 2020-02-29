#!/bin/sh

# fail on errors
set -e

cd chainblocks

# snappy
cd deps/snappy
mkdir build
cd build
cmake -G Ninja ..
ninja
cd ../../../

mkdir build
cd build
cmake -G Ninja -DBUILD_CORE_ONLY=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
ninja cb_static

cd ../../chainblocks-nim/

nimble install -y --depsonly
nimble test
