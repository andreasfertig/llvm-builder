#! /bin/bash

# ./llvm-release-build.sh /Users/builder/llvm/llvm-src 9.0.0

GIT_REPO=$1
LLVM_REV=$2

# split up af-clang-P0000 into clang, P0000
TYPE=`echo $2 | awk -F- '{print $2}'`
LLVM_REV=`echo $2 | awk -F- '{print $3}'`
BUILD_DIR=build_llvm-${LLVM_REV}
INSTALL_NAME=clang+llvm-${LLVM_REV}-x86_64-apple-darwin
INSTALL_PATH=/usr/local/${INSTALL_NAME}

if [ "$LLVM_REV" != "current" ]; then
  (cd ${GIT_REPO} && git checkout ${LLVM_REV})
else
  echo "Building current"
fi

mkdir -p ${BUILD_DIR}

cd ${BUILD_DIR}

if [ "${TYPE}" == "clang" ]; then
    cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_EXAMPLES=0 -DLLVM_INCLUDE_TESTS=1 -DCLANG_INCLUDE_TESTS=1 -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD=X86 ${GIT_REPO}/llvm
    cmake --build .
    ninja check-clang

elif [ "${TYPE}" == "libcxx" ]; then
    cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_EXAMPLES=0 -DLLVM_INCLUDE_TESTS=1 -DLIBCXX_INCLUDE_TESTS=1 -DLLVM_ENABLE_PROJECTS="libcxx;libcxxabi" -DLLVM_TARGETS_TO_BUILD=X86 ${GIT_REPO}/llvm
    ninja check-cxx
else
    echo "Unspported type ${TYPE}"
    exit 1
fi

umask 002
sudo mkdir -p ${INSTALL_PATH}
sudo chmod 0777 ${INSTALL_PATH}
ninja install
echo "${INSTALL_NAME}.tar.xz"
echo "tar -cJf $HOME/${INSTALL_NAME}.tar.xz -C ${INSTALL_PATH}"
tar -cJf $HOME/${INSTALL_NAME}.tar.xz -C ${INSTALL_PATH} ${INSTALL_PATH}
