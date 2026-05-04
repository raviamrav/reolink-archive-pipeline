@echo off
SET "MEGACMD_DIR=C:\Users\ravia\AppData\Local\MEGAcmd"
SET "INCOMING=/MEGA/Reolink_cams"
SET "ARCHIVE=/MEGA/Camera_Archive"

:: --- Get yesterday's date parts ---
FOR /F "tokens=1-3 delims=/" %%A IN ('powershell -NoProfile -Command "Get-Date (Get-Date).AddDays(-1) -Format MM/dd/yyyy"') DO (
    SET "MONTH=%%A"
    SET "DAY=%%B"
    SET "YEAR=%%C"
)

SET "YESTERDAY_PATH=%INCOMING%/%YEAR%/%MONTH%/%DAY%"
SET "ARCHIVE_PATH=%ARCHIVE%/%YEAR%/%MONTH%"

echo Today is: %DATE%
echo Moving yesterday's folder: %YESTERDAY_PATH%
echo Destination: %ARCHIVE_PATH%/%DAY%
echo.

:: Check login
"%MEGACMD_DIR%\MEGAclient.exe" whoami >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Not logged into MEGA.
    pause
    exit /b 1
)

:: Create destination path in archive if it doesn't exist
"%MEGACMD_DIR%\MEGAclient.exe" mkdir -p "%ARCHIVE_PATH%" >nul 2>&1

:: Check if folder exists before moving
"%MEGACMD_DIR%\MEGAclient.exe" ls "%YESTERDAY_PATH%" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Folder %YESTERDAY_PATH% not found - already archived or no recordings.
    goto :done
)

:: Move yesterday's day folder to archive
"%MEGACMD_DIR%\MEGAclient.exe" mv "%YESTERDAY_PATH%" "%ARCHIVE_PATH%/"

IF %ERRORLEVEL% EQU 0 (
    echo Done! Yesterday's recordings moved to Archive.
    echo Local copy will disappear once MEGA syncs.
) ELSE (
    echo ERROR: Move failed. Check that this path exists in MEGA:
    echo %YESTERDAY_PATH%
    echo.
    echo Run this to verify:
    echo "%MEGACMD_DIR%\MEGAclient.exe" ls "%INCOMING%/%YEAR%/%MONTH%"
)

:done
:: pause