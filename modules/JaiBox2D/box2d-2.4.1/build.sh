#!/usr/bin/env bash

# Use this to build box2d on any system with a bash shell
rm -rf build
mkdir build
cd build
cmake -DBOX2D_BUILD_DOCS=OFF -DBUILD_SHARED_LIBS=ON ..
cmake --build .
