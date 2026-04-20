@setlocal
@echo off
set "RTYPE=%1"
set "RARCH=%2"

for %%L in (cimgui cimplot cimplot3d cimnodes cimnodes_r cimguizmo cimguizmo_quat cimCTE) do (
    echo === Building %%L ===
    call "%~dp0build-native.cmd" "%RTYPE%" "%RARCH%" --lib "%%L"
    if errorlevel 1 exit /b 1
)
