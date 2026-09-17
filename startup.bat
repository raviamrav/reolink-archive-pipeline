@echo off
:: ============================================
:: Reolink Archive Pipeline - Startup Script
:: Run once as Administrator
:: ============================================

echo Setting up Reolink Archive Pipeline...
echo.

SET "MEGACMD_DIR=%LOCALAPPDATA%\MEGAcmd"
IF NOT EXIST "%MEGACMD_DIR%\MEGAclient.exe" SET "MEGACMD_DIR=%USERPROFILE%\AppData\Local\MEGAcmd"
SET "MEGA_CMD=%MEGACMD_DIR%\MEGAclient.exe"

IF NOT EXIST "%MEGA_CMD%" (
  echo ERROR: MEGAcmd was not found at "%MEGA_CMD%".
  echo Install MEGAcmd, log in once, and run this setup again.
  exit /b 1
)

echo MEGAcmd found at "%MEGA_CMD%".
echo Log in once before running this setup:
echo   "%MEGA_CMD%" login your@email.com
echo.

:: Remove the old password-based task from previous versions.
schtasks /delete /tn "MEGA Auto Login" /f >nul 2>&1

:: --- Task 1: n8n auto start on boot ---
echo [1/3] Registering n8n auto start...
schtasks /create /tn "n8n Auto Start" ^
  /tr "cmd.exe /c n8n start" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 2: server.js auto start on boot ---
echo [2/3] Registering server.js auto start...
schtasks /create /tn "n8n Runner Server" ^
  /tr "node C:\dev\portfolio\reolink-archive-pipeline\server.js" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 3: Failsafe backup at 10:15AM ---
echo [3/3] Registering failsafe backup archive task...
schtasks /create /tn "MEGA Reolink Archive Backup" ^
  /tr "C:\dev\portfolio\reolink-archive-pipeline\mega_archive.bat" ^
  /sc daily ^
  /st 10:15 ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Verify all tasks ---
echo ============================================
echo Verifying registered tasks...
echo ============================================
schtasks /query /tn "n8n Auto Start"
schtasks /query /tn "n8n Runner Server"
schtasks /query /tn "MEGA Reolink Archive Backup"

echo.
echo ============================================
echo Pipeline summary:
echo  [Boot]   n8n starts automatically
echo  [Boot]   server.js starts automatically
echo  [10:00]  n8n Schedule Trigger fires workflow
echo           HTTP Request to server.js
echo           mega_archive.bat runs
echo           Telegram notification sent
echo  [10:15]  Failsafe bat runs directly
echo ============================================
pause