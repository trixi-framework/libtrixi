#!/bin/bash

mkdir build
cd    build
cmake -DLIBTRIXI_PREFIX=$PWD/../../../install ..
make
