@echo off

echo Samples...
del samples\index.html /s 2>nul
del samples\build.hxml /s 2>nul
del samples\*.hl /s 2>nul
del samples\*.js /s 2>nul
del samples\buildAll.hxml 2>nul

echo Dump...
rmdir /Q/S dump 2>nul

echo Done.
echo.
pause