@echo off
:: ============================================
:: Reolink Archive Pipeline - Startup Script
:: Run once as Administrator
:: ============================================

echo Setting up Reolink Archive Pipeline...
echo.

:: --- Task 1: MEGA auto login on boot ---
echo [1/4] Registering MEGA auto login...
schtasks /create /tn "MEGA Auto Login" ^
  /tr "cmd.exe /c timeout /t 40 /nobreak && C:\Users\ravia\AppData\Local\MEGAcmd\MEGAclient.exe login raviamrav@yahoo.com Mega1.nz" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 2: n8n auto start on boot ---
echo [2/4] Registering n8n auto start...
schtasks /create /tn "n8n Auto Start" ^
  /tr "cmd.exe /c n8n start" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 3: server.js auto start on boot ---
echo [3/4] Registering server.js auto start...
schtasks /create /tn "n8n Runner Server" ^
  /tr "node C:\dev\portfolio\reolink-archive-pipeline\server.js" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 4: Failsafe backup at 10:15AM ---
echo [4/4] Registering failsafe backup archive task...
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
schtasks /query /tn "MEGA Auto Login"
schtasks /query /tn "n8n Auto Start"
schtasks /query /tn "n8n Runner Server"
schtasks /query /tn "MEGA Reolink Archive Backup"

echo.
echo ============================================
echo Pipeline summary:
echo  [Boot]   MEGA auto login (waits 30s first)
echo  [Boot]   n8n starts automatically
echo  [Boot]   server.js starts automatically
echo  [10:00]  n8n Schedule Trigger fires workflow
echo           HTTP Request to server.js
echo           mega_archive.bat runs
echo           Telegram notification sent
echo  [10:15]  Failsafe bat runs directly
echo ============================================
pause