#! /bin/bash

# ./llvm-release-build.sh /Users/builder/llvm/llvm-src 9.0.0

GIT_REPO=$1
LLVM_REV=$2
BUILD_DIR=build_llvm-${LLVM_REV}
INSTALL_NAME=clang+llvm-${LLVM_REV}-x86_64-apple-darwin
INSTALL_PATH=/usr/local/${INSTALL_NAME}

(cd ${GIT_REPO} && git checkout llvmorg-${LLVM_REV})

mkdir -p ${BUILD_DIR}

cd ${BUILD_DIR}

cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_EXAMPLES=0 -DLLVM_INCLUDE_TESTS=0 -DLLVM_ENABLE_PROJECTS="compiler-rt;clang;libcxx;libcxxabi" -DLLVM_ENABLE_CXX1Y=Yes -DLLVM_TARGETS_TO_BUILD=X86 ${GIT_REPO}/llvm

cmake --build .

umask 002
sudo mkdir -p /usr/local/${INSTALL_NAME}
sudo ./ninja install
sudo tar -cJf ${INSTALL_NAME}.tar.xz -C /usr/local/${INSTALL_NAME}
