@echo off

echo Samples...
del samples\*.hxml 2>nul
del samples\*.html 2>nul
rmdir /Q/S samples\bin 2>nul

echo Dump...
rmdir /Q/S dump 2>nul

echo Done.
echo.
pause