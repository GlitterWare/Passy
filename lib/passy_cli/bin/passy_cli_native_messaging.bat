@echo off
SET "PASSY_PATH=%~dp0passy_cli.exe"
:Start
FOR /F "tokens=* USEBACKQ" %%F IN (`call "%%PASSY_PATH%%" install temp`) DO (SET PASSY_TEMP_PATH=%%F)
call "%%PASSY_TEMP_PATH%%" native_messaging start
GOTO:Start
