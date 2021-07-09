@setlocal
@echo off

copy %~dp0cimgui\generator\output\*.json %~dp0..\ImGui.NET\src\CodeGenerator\definitions\cimgui
copy %~dp0cimguizmo\generator\output\*.json %~dp0..\ImGui.NET\src\CodeGenerator\definitions\cimguizmo
copy %~dp0cimnodes\generator\output\*.json %~dp0..\ImGui.NET\src\CodeGenerator\definitions\cimnodes
copy %~dp0cimplot\generator\output\*.json %~dp0..\ImGui.NET\src\CodeGenerator\definitions\cimplot

cmd /k