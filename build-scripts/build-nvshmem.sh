#!/bin/bash

here="`pwd`"
topdir="`dirname ${here}`"
nvshmem_version="3.5.19-1"
srcdir="${topdir}/nvshmem-${nvshmem_version}"
openmpi="/usr/lib64/openmpi"
openmpi_libdir="${openmpi}/lib"
cuda_version="12.9"
cuda_home="/usr/local/cuda-${cuda_version}"
cuda_architectures="89"
cmake_install_prefix="/usr/local"
cmake_install_libdir="${cmake_install_prefix}/lib64"
cmake_build_rpath="${cuda_home}/lib64;${here}/lib64;${openmpi_libdir}"
cmake_install_rpath="${cuda_home}/lib64;${cuda_home}/targets/x86_64-linux/lib;${openmpi_libdir};${cmake_install_libdir}"
openmpi="/usr/lib64/openmpi"
cmake_outfile="${here}/cmake-configure-nvshmem.out"
outfile="${here}/build-nvshmem.out"
njobs=4
rc=0

export PATH="${cuda_home}/bin:${openmpi}/bin:${PATH}"
export CUDA_HOME="${cuda_home}"
export MPI_HOME="${openmpi}"
export LIBFABRIC_HOME="/usr"
export GDRCOPY_HOME="/usr"
export SHMEM_HOME="/usr/local"
export GDRCOPY_HOME="/usr"
export NCCL_HOME="/usr"
export UCX_HOME="/usr"
export NVSHMEM_PREFIX="/usr/local"
export NVSHMEM_CLANG_DIR="/usr"
export NVSHMEM_MPI_SUPPORT=1
export NVSHMEM_VERBOSE=1
export CUTLASS_HOME="${cuda_home}"
export PKG_CONFIG_PATH="${cuda_home}/lib64/pkgconfig:${openmpi}/lib/pkgconfig:/usr/local/lib64/pkgconfig:${PKG_CONFIG_PATH}"
export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"
export CFLAGS="-Wall -Wextra"
export CXXFLAGS="-Wall -Wextra"

cat /dev/null > ${outfile}

echo "Running gmake -j${njobs} >> ${outfile} 2>&1 ..."
gmake -j${njobs} >> ${outfile} 2>&1
rc=$?

if [ ${rc} -ne 0 ] ; then
  echo "nvshmem build FAILED."
  exit 1
else
  echo "nvshmem build OK."
fi

