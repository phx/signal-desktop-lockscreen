@ECHO OFF&& SETLOCAL&& PUSHD "%~dp0"&& SETLOCAL ENABLEDELAYEDEXPANSION&& SETLOCAL ENABLEEXTENSIONS&& SET V=5&& IF NOT "!V!"=="5" (ECHO DelayedExpansion Failed&& GOTO :EOF)

REM ** Various vars for output used by functions
SET P1=^^^>^^^>^^^>
SET P2=++
SET P3=::
SET L1=+==============================================================================================================+
SET L2=+--------------------------------------------------------------------------------------------------------------+
SET "SIGNAL_DIR=%APPDATA%\..\Local\Programs\signal-desktop\resources"
IF NOT EXIST %SIGNAL_DIR%\NUL CALL :END "Signal Desktop installation not found." & GOTO:EOF
SET "PASSWD_KEY=%APPDATA%\..\Roaming\Signal\.lockkey"

WHERE npm >NUL 2>&1
IF ERRORLEVEL 1 CALL :END "This patch requires npm to be installed" & GOTO:EOF
WHERE asar >NUL 2>&1
IF ERRORLEVEL 1 npm install -g asar

REM Make sure that Signal config directory has been created by launching signal once before killing to do work:
CALL :RESTART_SIGNAL
COPY /Y %SIGNAL_DIR%\app.asar . >NUL
XCOPY /Y /E /I %SIGNAL_DIR%\app.asar.unpacked app.asar.unpacked >NUL
ECHO Extracting archive...
CALL asar extract app.asar app.asar.unpacked
DEL /Q app.asar

FINDSTR /I lockscreen.js app.asar.unpacked\background.html >NUL 2>&1
#IF ERRORLEVEL 1 POWERSHELL (Get-Content -path .\app.asar.unpacked\background.html) -replace '^<script type=.text/javascript. src=.js/wall_clock_listener.js.^>^</script^>.*','   ^<script type=''text/javascript'' src=''js/wall_clock_listener.js''^>^</script^>^<script type=''text/javascript'' src=''js/lockscreen.js''^>^</script^>' > background.html
IF ERRORLEVEL 1 POWERSHELL (Get-Content -path .\app.asar.unpacked\background.html) -replace '^</body^>','   ^<script type=''text/javascript'' src=''js/lockscreen.js''^>^</script^>^</body^>' > background.html
SET TMPPASS=%PASSWD_KEY:\=/%
SET TMPPASS=%TMPPASS:../Roaming/=%
CALL POWERSHELL (Get-Content -path .\lockscreen.template.js) -replace '\*\*\*LOCK_KEY_FILE_HERE\*\*\*','%TMPPASS%' > lockscreen.js
MOVE /Y background.html app.asar.unpacked\background.html >NUL 2>&1
MOVE /Y lockscreen.js app.asar.unpacked\js\lockscreen.js >NUL

ECHO Packing archive...
TASKKILL /IM Signal.exe >NUL 2>&1
CALL asar pack app.asar.unpacked app.asar
RMDIR /S /Q app.asar.unpacked
MOVE /Y app.asar %SIGNAL_DIR%\ >NUL

IF NOT EXIST %PASSWD_KEY% CALL :SET_PASSWD_KEY

@ECHO.
ECHO Done.
CALL :RESTART_SIGNAL & GOTO:EOF

:: SUBROUTINES
REM =========================================================================================================================================================================
REM =   RESTART_SIGNAL - restart Signal.exe, then returns to CALLer
REM =========================================================================================================================================================================
:RESTART_SIGNAL
TASKKILL /IM Signal.exe >NUL 2>&1
CMD /C "@START %SIGNAL_DIR%\..\Signal.exe"
EXIT /B
REM =========================================================================================================================================================================
REM =   SET_PASSWD_KEY - creates .lockkey, then returns to CALLer
REM =========================================================================================================================================================================
:SET_PASSWD_KEY
@ECHO.
SET /P "PASS1=Please type the passphrase you wish to use to unlock Signal: "
SET /P "PASS2=Please re-type the password for verification: "
IF NOT "%PASS1%" == "%PASS2%" ECHO Passwords do not match & GOTO:SET_PASSWD_KEY
ECHO %PASS1%>%PASSWD_KEY%
EXIT /B
REM =========================================================================================================================================================================
REM =   END - exit script with message %~1, then returns to CALLer
REM =========================================================================================================================================================================
:END
SETLOCAL
SET _M= %~1
IF NOT "%_M%" == " " SET _M=REASON: %~1
CALL :MP 1 "EXITING SCRIPT...  %_M%" && ECHO. && ECHO.
ENDLOCAL
EXIT /B
