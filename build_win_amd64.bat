@echo off

set CURRPATH=%cd%

if not exist "%CURRPATH%\config_win.bat" (
	echo You need to create config_win.bat using config_win.template
	goto eof
)

call "%CURRPATH%\config_win.bat"
call "%CURRPATH%\build_win.bat" amd64

:eof