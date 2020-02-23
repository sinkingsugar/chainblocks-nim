#!/bin/sh

# fail on errors
set -e

# cd chainblocks

# # snappy
# cd deps/snappy
# mkdir build
# cd build
# cmake -G Ninja ..
# ninja
# cd ../../../

# mkdir build
# cd build
# cmake -G Ninja -DBUILD_CORE_ONLY=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
# ninja cbl && ninja cb_shared
# ./cbl ../src/tests/general.clj
# ./cbl ../src/tests/variables.clj
# ./cbl ../src/tests/subchains.clj
# ./cbl ../src/tests/linalg.clj
# ./cbl ../src/tests/loader.clj
# ./cbl ../src/tests/network.clj
# ./cbl ../src/tests/struct.clj
# ./cbl ../src/tests/flows.clj
# ./cbl ../src/tests/snappy.clj
# ./cbl ../src/tests/stack.clj
# ./cbl ../src/tests/kdtree.clj

# mkdir -p ../../chainblocks-rs/target/debug
# cp libcb_shared.so ../../chainblocks-rs/target/debug/

# cd ../../chainblocks-nim/

cd chainblocks-nim

nimble install -y --depsonly
nimble test
