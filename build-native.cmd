@setlocal
@echo off

set "BUILD_CONFIG=Debug"
set "BUILD_ARCH=x64"
set "BUILD_CMAKE_GENERATOR_PLATFORM=x64"
set "MSVC_RUNTIME=MultiThreadedDebug"
set "BUILD_LIB=cimgui"
set "BUILD_CXX_WARNING_FLAGS=/wd4190 /wd4244 /wd4305 /wd4715 /wd4996"

:ArgLoop
if [%~1] == [] goto Build
if /i [%~1] == [Release] (set "BUILD_CONFIG=Release" && set "MSVC_RUNTIME=MultiThreaded" && shift & goto ArgLoop)
if /i [%~1] == [Debug] (set "BUILD_CONFIG=Debug" && set "MSVC_RUNTIME=MultiThreadedDebug" && shift & goto ArgLoop)
if /i [%~1] == [x64] (set "BUILD_ARCH=x64" && shift & goto ArgLoop)
if /i [%~1] == [ARM64] (set "BUILD_ARCH=ARM64" && set "BUILD_CMAKE_GENERATOR_PLATFORM=ARM64" && shift & goto ArgLoop)
if /i [%~1] == [ARM] (set "BUILD_ARCH=ARM" && set "BUILD_CMAKE_GENERATOR_PLATFORM=ARM" && shift & goto ArgLoop)
if /i [%~1] == [x86] (set "BUILD_ARCH=x86" && set "BUILD_CMAKE_GENERATOR_PLATFORM=Win32" && shift & goto ArgLoop)
if /i [%~1] == [--lib] (set "BUILD_LIB=%~2" && shift && shift & goto ArgLoop)
shift
goto ArgLoop

:Build
set "LIB_ROOT=%~dp0%BUILD_LIB%"

rem Inject override CMakeLists.txt if the lib doesn't have its own
set "OVERRIDE_CMAKE=%~dp0cmake\%BUILD_LIB%\CMakeLists.txt"
if exist "%OVERRIDE_CMAKE%" (
    copy /Y "%OVERRIDE_CMAKE%" "%LIB_ROOT%\CMakeLists.txt" >nul
)

set "PATCH_FILE=%~dp0patches\%BUILD_LIB%.patch"
if exist "%PATCH_FILE%" (
    git -C "%LIB_ROOT%" apply --check "%PATCH_FILE%" >nul 2>nul
    if not errorlevel 1 git -C "%LIB_ROOT%" apply "%PATCH_FILE%"
)

If NOT exist "%LIB_ROOT%\build\%BUILD_ARCH%" (
  mkdir "%LIB_ROOT%\build\%BUILD_ARCH%"
)
pushd "%LIB_ROOT%\build\%BUILD_ARCH%"
cmake -DCMAKE_GENERATOR_PLATFORM=%BUILD_CMAKE_GENERATOR_PLATFORM% -DCMAKE_MSVC_RUNTIME_LIBRARY=%MSVC_RUNTIME% -DCMAKE_CXX_FLAGS="%BUILD_CXX_WARNING_FLAGS%" ..\..
if errorlevel 1 exit /b 1

echo Calling cmake --build . --config %BUILD_CONFIG%
cmake --build . --config %BUILD_CONFIG%
if errorlevel 1 exit /b 1
popd

:Success
exit /b 0
