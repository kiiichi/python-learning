@echo OFF

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

if %OS%==32BIT START "" "%~dp0CP210xVCPInstaller_x86.exe"
if %OS%==64BIT START "" "%~dp0CP210xVCPInstaller_x64.exe"
