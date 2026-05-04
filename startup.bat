@echo off
:: ============================================
:: Reolink Archive Pipeline - Startup Script
:: Run once as Administrator
:: ============================================

echo Setting up Reolink Archive Pipeline...
echo.

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
  /tr "cmd.exe /c node C:\Users\ravia\Documents\n8n_runner\server.js" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 3: Failsafe backup at 10:15AM ---
:: Note: Primary 10AM trigger is handled by n8n Schedule node internally
:: This runs mega_archive.bat directly as a safety net
:: if n8n is stopped or crashes
echo [3/3] Registering failsafe backup archive task...
schtasks /create /tn "MEGA Reolink Archive Backup" ^
  /tr "C:\Users\ravia\Documents\mega_archive.bat" ^
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
echo           Already archived - exits cleanly
echo ============================================
pause