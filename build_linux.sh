#!/bin/bash

#Get current worker folder
CURRENT_DIR=`pwd`
ARCH=$1

if [ ! -f "$CURRENT_DIR/config_linux.sh" ]; then
	echo "you need to create config_linux.sh using config_linux.template as base"
	exit 1
fi

#call config_linux.sh
source $CURRENT_DIR/config_linux.sh

if [ -z "$ANDROID_NDK_HOME" ]; then
	echo "You need add your current Android NDK Path in config_linux.sh based in config_linux.template"
	exit 1
fi

if [ -z "$ARCH" ]; then
	echo "You need add set the ARCH for lldb "
	exit 1
fi

if [ "$ARCH" = "aarch64" ]; then
	_ANDROID_ABI=arm64-v8a
	_HOST_TRIPLE=aarch64
fi

if [ "$ARCH" = "arm" ]; then
	_ANDROID_ABI=armeabi-v7a
	_HOST_TRIPLE=arm
fi

if [ "$ARCH" = "x86" ]; then
	_ANDROID_ABI=x86
	_HOST_TRIPLE=i386
fi

if [ "$ARCH" = "x86_64" ]; then
	_ANDROID_ABI=x86_64
	_HOST_TRIPLE=x86_64
fi


BUILD_PATH=$CURRENT_DIR/build_$ARCH

#LLVM Svn urls
LLVM_SVN_URL=https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_600/final
CLANG_SVN_URL=https://llvm.org/svn/llvm-project/cfe/tags/RELEASE_600/final
LLDB_SVN_URL=https://llvm.org/svn/llvm-project/lldb/tags/RELEASE_600/final

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
	cmake -G Ninja $LLVM -DCMAKE_BUILD_TYPE=MinSizeRel -Wno-dev -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake -DANDROID_ABI=$_ANDROID_ABI -DANDROID_PLATFORM=android-21 -DLLVM_HOST_TRIPLE=$_HOST_TRIPLE-unknown-linux-android -DCMAKE_C_FLAGS="-s" -DCMAKE_CXX_FLAGS="-s"
fi

#Get Number of threads
NPROC=`nproc`

if [ -f "$BUILD_PATH/build.ninja" ]; then
	ninja lldb-server -j $NPROC
fi

cd $CURRENT_DIR 
