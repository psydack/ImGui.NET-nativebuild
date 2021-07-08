@setlocal
@echo off

(
    cd %~dp0/cimgui/generator
    start generator.bat

    cd %~dp0/cimguizmo/generator
    start generator.bat

    cd %~dp0/cimnodes/generator
    start generator.bat

    cd %~dp0/cimplot/generator
    start  generator.bat

    cd %~dp0
) | pause

exit 0