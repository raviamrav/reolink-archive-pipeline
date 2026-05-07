@echo off
:: ============================================
:: CONFIGURATION
:: ============================================
SET "MEGACMD_DIR=C:\Users\ravia\AppData\Local\MEGAcmd"
SET "INCOMING=/MEGA/Reolink_cams"
SET "ARCHIVE=/MEGA/Camera_Archive"
SET "PROJECT_DIR=C:\dev\portfolio\reolink-archive-pipeline"

:: ============================================
:: STEP 1 - Ensure MEGA is logged in
:: ============================================
echo [1/4] Checking MEGA login...
"%MEGACMD_DIR%\MEGAclient.exe" whoami >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo MEGA not logged in. Logging in...
    "%MEGACMD_DIR%\MEGAclient.exe" login raviamrav@yahoo.com Mega1.nz
) ELSE (
    echo MEGA already logged in.
)

:: ============================================
:: STEP 2 - Ensure n8n is running
:: ============================================
echo [2/4] Checking n8n...
netstat -ano | findstr ":5678" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo n8n not running. Starting...
    start /min "n8n Service" cmd /c "n8n start"
    timeout /t 30 /nobreak >nul
    echo n8n started.
) ELSE (
    echo n8n already running.
)

:: ============================================
:: STEP 3 - Ensure server.js is running
:: ============================================
echo [3/4] Checking server.js...
netstat -ano | findstr ":3000" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo server.js not running. Starting...
    start /min "n8n Runner" cmd /c "node %PROJECT_DIR%\server.js"
    timeout /t 5 /nobreak >nul
    echo server.js started.
) ELSE (
    echo server.js already running.
)

:: ============================================
:: STEP 4 - Run archive
:: ============================================
echo [4/4] Running archive...


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