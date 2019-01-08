#!/bin/bash

#Get current worker folder
CURRENT_DIR=`pwd`
ANDROID_NDK_HOME=/home/whiso/android-ndk-r18b
ARCH=arm

if [ -z "$ANDROID_NDK_HOME" ]; then
	echo "You need add your current Android NDK Path "
	exit 1
fi

if [ -z "$ARCH" ]; then
	echo "You need add set the ARCH for lldb server "
	exit 1
fi

BUILD_PATH=$CURRENT_DIR/build_$ARCH

#LLVM Svn urls
LLVM_SVN_URL=https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_701/final
CLANG_SVN_URL=https://llvm.org/svn/llvm-project/cfe/tags/RELEASE_701/final
LLDB_SVN_URL=https://llvm.org/svn/llvm-project/lldb/tags/RELEASE_701/final

#LLVM Working path
LLVM_PATH=$CURRENT_DIR/llvm
LLVM=$CURRENT_DIR/llvm/llvm
LLDB=$CURRENT_DIR/llvm/lldb
CLANG=$CURRENT_DIR/llvm/clang


if [ -z "$ANDROID_NDK_HOME" ]; then
	echo "You need add your current Android NDK Path "
	exit 1
fi

if [ ! -d "$LLVM_PATH" ]; then
	#Create LLVM Working path
	mkdir $LLVM_PATH 
fi

if [ ! -d "$LLVM" ]; then
	#Download SVN source
	svn co $LLVM_SVN_URL $LLVM
fi

if [ ! -d "$LLDB" ]; then
	#Download SVN source
	svn co $LLDB_SVN_URL $LLDB
fi

if [ ! -d "$CLANG" ]; then
	#Download SVN source
	svn co $CLANG_SVN_URL $CLANG
fi

if [ ! -d "$LLVM/tools/lldb" ]; then
	ln -s $LLDB $LLVM/tools/lldb
fi

if [ ! -d "$LLVM/tools/clang" ]; then
	ln -s $CLANG $LLVM/tools/clang
fi

if [ ! -d "$BUILD_PATH" ]; then
	mkdir $BUILD_PATH
fi

cd $BUILD_PATH

if [ ! -f "$BUILD_PATH/build.ninja" ]; then
	cmake -G Ninja $LLVM -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21 -DANDROID_ALLOW_UNDEFINED_SYMBOLS=On -DLLVM_HOST_TRIPLE=aarch64-unknown-linux-android -DCROSS_TOOLCHAIN_FLAGS_NATIVE='-DCMAKE_C_COMPILER=cc;-DCMAKE_CXX_COMPILER=c++' 
fi

#Get Number of threads
NPROC=`nproc`

ninja -j $NPROC

cd $CURRENT_DIR 
