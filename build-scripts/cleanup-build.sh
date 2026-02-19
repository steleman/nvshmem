#!/bin/bash

here="`pwd`"
tophere="`dirname ${here}`"
version="3.5.19-1"
srcdir="${tophere}/nvshmem-${version}"
srcbuilddir="${srcdir}/build"

rm -rf CMakeCache.txt CMakeFiles src *.cmake License.txt \
  _deps lib bin Makefile nvshmem4py ${srcbuilddir}

