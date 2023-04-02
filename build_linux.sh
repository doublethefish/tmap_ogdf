#!/usr/bin/env sh
# © 2019-2023 Frank Harrison All Rights Reserved

set -o pipefail
set -e

cd ./ogdf-conda/src
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./libOGDFTmap -DBUILD_SHARED_LIBS=ON
make -j4
make install
cd ..
