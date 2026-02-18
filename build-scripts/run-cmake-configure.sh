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
outfile="${here}/configure-nvshmem.out"
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

cmake_flags="-DCMAKE_INSTALL_PREFIX=${cmake_install_prefix}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_LIBDIR=${cmake_install_libdir}"
cmake_flags="${cmake_flags} -DCMAKE_BUILD_TYPE=Release"
cmake_flags="${cmake_flags} -DNVSHMEM_UCX_SUPPORT=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_MPI_SUPPORT=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_USE_NCCL=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_BUILD_WITH_CUTLASS=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_BUILD_PACKAGES=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_BUILD_RPM_PACKAGE=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_BUILD_BITCODE_LIBRARY=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_SHMEM_SUPPORT=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_LIBFABRIC_SUPPORT=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_PMIX_SUPPORT=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_DEFAULT_UCX=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_DEFAULT_PMIX=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_ENABLE_ALL_DEVICE_INLINING=ON"
cmake_flags="${cmake_flags} -DNVSHMEM_CLANG_DIR=/usr"
cmake_flags="${cmake_flags} -DNVSHMEM_BUILD_BITCODE_LIBRARY=ON"
cmake_flags="${cmake_flags} -DLIBFABRIC_HOME=${LIBFABRIC_HOME}"
cmake_flags="${cmake_flags} -DGDRCOPY_HOME=${GDRCOPY_HOME}"
cmake_flags="${cmake_flags} -DSHMEM_HOME=${SHMEM_HOME}"
cmake_flags="${cmake_flags} -DNCCL_HOME=${NCCL_HOME}"
cmake_flags="${cmake_flags} -DUCX_HOME=${UCX_HOME}"
cmake_flags="${cmake_flags} -DNVSHMEM_CLANG_DIR=${NVSHMEM_CLANG_DIR}"
cmake_flags="${cmake_flags} -DNVSHMEM_PREFIX=${NVSHMEM_PREFIX}"
cmake_flags="${cmake_flags} -DCMAKE_CUDA_ARCHITECTURES=89"
cmake_flags="${cmake_flags} -DCMAKE_C_COMPILER=${CC}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_COMPILER=${CXX}"
cmake_flags="${cmake_flags} -DCMAKE_C_FLAGS=${CFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_FLAGS=${CXXFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_VERBOSE_MAKEFILE=ON"
cmake_flags="${cmake_flags} -DCMAKE_SUPPRESS_REGENERATION=ON"
cmake_flags="${cmake_flags} -DCMAKE_EXE_LINKER_FLAGS=-fPIE"
cmake_flags="${cmake_flags} -DCMAKE_SHARED_LINKER_FLAGS=-fPIC"
cmake_flags="${cmake_flags} -DCMAKE_MODULE_LINKER_FLAGS=-fPIC"
cmake_flags="${cmake_flags} -DCMAKE_BUILD_RPATH=${cmake_build_rpath}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_RPATH=${cmake_install_rpath}"

cat /dev/null > ${outfile}

echo "Running cmake ${cmake_flags} ${srcdir} ..."
echo "Running cmake ${cmake_flags} ${srcdir} ..." > ${cmake_outfile} 2>&1
cmake ${cmake_flags} ${srcdir} >> ${outfile} 2>&1
rc=$?

if [ ${rc} -ne 0 ] ; then
  echo "CMake Configuration FAILED."
  exit 1
else
  echo "CMake Configuration OK."
fi

echo "mkdir -p ${here}/src/llvm_lib"
mkdir -p ${here}/src/llvm_lib

for file in \
  ${here}/src/CMakeFiles/nvshmem_bootstrap_shmem.dir/link.txt
do
  echo "patching link file ${file} for shmem ..."
  sed -i 's#/usr/local/lib64/libshmem.so# -Wl,--as-needed /usr/local/lib64/libshmem.so /usr/local/lib64/libshmemc-ucx.so /usr/local/lib64/libshmemt.so /usr/local/lib64/libshmemu.so /usr/local/lib64/libshmem-amo.so /usr/local/lib64/libshcoll.so -Wl,--no-as-needed #g' ${file}
done

if [ ! -e ${srcdir}/build/.patched ] ; then
  echo "cd ${srcdir}/build"
  cd ${srcdir}/build

  listfile="/tmp/shmemlink.$$"
  cat /dev/null > ${listfile}

  find . -type f -name 'link.txt' -print >> ${listfile}

  while read -r line
  do
    echo "patching link file ${line} for shmem ..."
    sed -i 's#/usr/local/lib64/libshmem.so# -Wl,--as-needed /usr/local/lib64/libshmem.so /usr/local/lib64/libshmemc-ucx.so /usr/local/lib64/libshmemt.so /usr/local/lib64/libshmemu.so /usr/local/lib64/libshmem-amo.so /usr/local/lib64/libshcoll.so -Wl,--no-as-needed#g' ${line}
  done < ${listfile}

  rm -f ${listfile}
  touch .patched
  echo "cd ${here}"
  cd ${here}
fi

