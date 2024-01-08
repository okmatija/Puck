@echo off

jai first.jai
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

copy /Y pong.exe C:\Users\matij\Dropbox\pong\pong.exe
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

start /B "" "pong.exe" 1100 400
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo "Success"