@echo off

set LLVM_SVN_URL=https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_600/final
set CLANG_SVN_URL=https://llvm.org/svn/llvm-project/cfe/tags/RELEASE_600/final
set LLDB_SVN_URL=https://llvm.org/svn/llvm-project/lldb/tags/RELEASE_600/final

set CURRENT_PATH_ENV=%PATH%
set PATH=%~dp0tools\GetGnuWin32\bin;%~dp0tools\swigwin-3.0.5;%~dp0tools\cmake-3.8.0-rc2-win64-x64\bin;%~dp0tools\svn\bin;%PATH%
set LLVM_PATH=%~dp0llvm
set LLVM=%~dp0llvm\llvm
set LLDB=%~dp0llvm\lldb
set CLANG=%~dp0llvm\clang
set PYTHON_HOME=%PYTHON_PATH%

if "%PYTHON_PATH%"=="" (
	echo you need to add Python path in config_win.bat -- take config_win.template as base --
	goto eof
)

set ARCH=%1
set BUILD=build_%ARCH%

SetLocal EnableDelayedExpansion

if "%VS140COMNTOOLS%"=="" (
	rem USE 2017 enviorement
 	set "VS150COMNTOOLS=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\"
 	set VC_VARALL_SCRIPT=!VS150COMNTOOLS!..\..\VC\Auxiliary\Build\vcvarsall.bat
) else (
	set VSTOOLS=!VS140COMNTOOLS!
 	set VC_VARALL_SCRIPT=!VSTOOLS!..\..\VC\vcvarsall.bat
)

rem Create LLVM path 
if not exist "%LLVM_PATH%" (
	mkdir "%LLVM_PATH%"
)

if not exist "%LLVM%" (
	rem make SVN checkout
	svn co %LLVM_SVN_URL% "%LLVM%"
)

if not exist "%LLDB%" (
	rem make SVN checkout
	svn co %LLDB_SVN_URL% "%LLDB%"
)

if not exist "%CLANG%" (
	rem make SVN checkout
	svn co %CLANG_SVN_URL% "%CLANG%"
)


if not exist "%LLVM%\tools\lldb" (
	mklink /j "%LLVM%\tools\lldb" "%LLDB%"
)

if not exist "%LLVM%\tools\clang" (
	mklink /j "%LLVM%\tools\clang" "%CLANG%"
)

call "%VC_VARALL_SCRIPT%" %ARCH%

set INCLUDE=%INCLUDE%;%~dp0external

if not exist "%BUILD%" (
	mkdir %BUILD%
)

pushd %BUILD%

if not exist build.ninja (
   cmake -G Ninja "%~dp0llvm\llvm" -DCMAKE_BUILD_TYPE=Release -DPYTHON_HOME=%PYTHON_PATH%\ -DPYTHON_EXECUTABLE=%PYTHON_PATH%\python.exe -DLLVM_TARGETS_TO_BUILD="X86;ARM;AArch64" -DLLDB_RELOCATABLE_PYTHON=1 -DSWIG_DIR=%~dp0tools\swigwin-3.0.5 -DSWIG_EXECUTABLE=%~dp0tools\swigwin-3.0.5\swig.exe
)

if exist build.ninja (
	ninja lldb finish_swig -j %NUMBER_OF_PROCESSORS%
)

set PATH=%CURRENT_PATH_ENV%

popd

:eof