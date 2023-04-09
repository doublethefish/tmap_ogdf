#!/usr/bin/env sh
# © 2019-2023 Frank Harrison All Rights Reserved

set -o pipefail
set -e

brew install libomp || brew reinstall libomp
cd ./ogdf-conda/src
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON
make -j4
make install
cd ..