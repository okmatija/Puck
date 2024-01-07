jai first.jai
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

copy /Y pong.exe C:\Users\matij\Dropbox\pong\pong.exe
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

pong.exe
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%