@ECHO OFF

PUSHD C:\Program Files (x86)\Microsoft Visual Studio\2019\Community
CALL VC\Auxiliary\Build\vcvars64.bat
POPD

SET OUTDIR=out
IF NOT EXIST %OUTDIR% (MKDIR %OUTDIR%)
PUSHD %OUTDIR%
cmake -G Ninja ^
    -DWITH_GFLAGS=on ^
    -Dgflags_DIR=%~dp0..\..\gflags\src\out\ ^
    -DCMAKE_INSTALL_PREFIX=%~dp0..\ ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..\glog-0.4.0
IF %ERRORLEVEL% == 0 (ninja && ninja install)
POPD
