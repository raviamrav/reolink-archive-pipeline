@echo off
:: ============================================
:: CONFIGURATION
:: ============================================
IF DEFINED LOCALAPPDATA (
    SET "MEGACMD_DIR=%LOCALAPPDATA%\MEGAcmd"
) ELSE (
    SET "MEGACMD_DIR=%USERPROFILE%\AppData\Local\MEGAcmd"
)

IF NOT EXIST "%MEGACMD_DIR%\MEGAclient.exe" (
    SET "MEGACMD_DIR=%USERPROFILE%\AppData\Local\MEGAcmd"
)

SET "MEGA_CMD=%MEGACMD_DIR%\MEGAclient.exe"
SET "LOCAL_INCOMING=C:\Reolink_FTP"
SET "INCOMING=/MEGA/Reolink_cams"
SET "ARCHIVE=/MEGA/Camera_Archive"
SET "PROJECT_DIR=C:\dev\portfolio\reolink-archive-pipeline"

:: Optional: set these environment variables before running the script
::   set MEGA_EMAIL=your@email.com
::   set MEGA_PASSWORD=your_password

:: ============================================
:: STEP 1 - Ensure MEGA is installed and logged in
:: ============================================
echo [1/4] Checking MEGA login...
IF NOT EXIST "%MEGA_CMD%" (
    echo ERROR: MEGAcmd not found at "%MEGA_CMD%".
    echo Install MEGAcmd from: https://mega.io/cmd
    exit /b 1
)

"%MEGA_CMD%" whoami >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo MEGA not logged in. Attempting login...
    IF NOT "%MEGA_EMAIL%"=="" IF NOT "%MEGA_PASSWORD%"=="" (
        "%MEGA_CMD%" login "%MEGA_EMAIL%" "%MEGA_PASSWORD%"
    ) ELSE (
        echo Please log in once with:
        echo   "%MEGA_CMD%" login your@email.com
        echo or set MEGA_EMAIL and MEGA_PASSWORD in your environment before running this script.
        exit /b 1
    )
) ELSE (
    echo MEGA already logged in.
)

:: ============================================
:: STEP 2 - Ensure n8n is installed and running
:: ============================================
echo [2/4] Checking n8n...
where n8n >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: n8n is not installed.
    echo Install it with: npm install -g n8n
    exit /b 1
)

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
:: STEP 3 - Ensure Node.js and server.js are available
:: ============================================
echo [3/4] Checking server.js...
where node >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js is not installed or not on PATH.
    echo Install Node.js LTS from https://nodejs.org
    exit /b 1
)

IF NOT EXIST "%PROJECT_DIR%\server.js" (
    echo ERROR: server.js not found at "%PROJECT_DIR%\server.js".
    exit /b 1
)

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

:: Check login
"%MEGA_CMD%" whoami >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Not logged into MEGA.
    echo Run: "%MEGA_CMD%" login your@email.com
    exit /b 1
)

:: Discover all local date folders. Today is deliberately excluded.
IF NOT EXIST "%LOCAL_INCOMING%" (
    echo ERROR: Local recording folder not found: "%LOCAL_INCOMING%"
    echo Update LOCAL_INCOMING near the top of this script.
    exit /b 1
)

echo Today is: %DATE%
echo Scanning completed recording folders under: %LOCAL_INCOMING%
echo.

FOR /F "tokens=1-3" %%A IN ('powershell -NoProfile -Command "$today=(Get-Date).Date; Get-ChildItem -LiteralPath '%LOCAL_INCOMING%' -Directory | Where-Object { $_.Name -match '^[0-9]{4}$' } | ForEach-Object { $year=$_.Name; Get-ChildItem -LiteralPath $_.FullName -Directory | Where-Object { $_.Name -match '^(0[1-9]|1[0-2])$' } | ForEach-Object { $month=$_.Name; Get-ChildItem -LiteralPath $_.FullName -Directory | Where-Object { $_.Name -match '^(0[1-9]|[12][0-9]|3[01])$' } | ForEach-Object { $day=[int]$_.Name; $date=[datetime]::new([int]$year,[int]$month,$day); if ($date -lt $today) { Write-Output ($year + [char]32 + $month + [char]32 + $_.Name) } } } }"') DO (
    CALL :ARCHIVE_DATE "%%A" "%%B" "%%C"
)

:done
:: pause
exit /b 0

:ARCHIVE_DATE
SET "YEAR=%~1"
SET "MONTH=%~2"
SET "DAY=%~3"
SET "TARGET_PATH=%INCOMING%/%YEAR%/%MONTH%/%DAY%"
SET "ARCHIVE_PATH=%ARCHIVE%/%YEAR%/%MONTH%"

echo Checking: %TARGET_PATH%
"%MEGA_CMD%" ls "%TARGET_PATH%" >nul 2>&1
IF ERRORLEVEL 1 (
    echo Folder is not present in MEGA; leaving it untouched.
    exit /b 0
)

"%MEGA_CMD%" mkdir -p "%ARCHIVE_PATH%" >nul 2>&1
"%MEGA_CMD%" mv "%TARGET_PATH%" "%ARCHIVE_PATH%/"
IF ERRORLEVEL 1 (
    echo ERROR: Move failed for %TARGET_PATH%.
) ELSE (
    echo Archived: %TARGET_PATH%
)
exit /b 0