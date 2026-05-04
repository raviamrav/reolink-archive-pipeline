@echo off
:: ============================================
:: Reolink Archive Pipeline - Startup Script
:: Registers all required scheduled tasks
:: Run this once as Administrator
:: ============================================

echo Setting up Reolink Archive Pipeline...
echo.

:: --- Task 1: n8n auto start on boot ---
echo [1/4] Registering n8n auto start...
schtasks /create /tn "n8n Auto Start" ^
  /tr "cmd.exe /c n8n start" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 2: server.js auto start on boot ---
echo [2/4] Registering server.js auto start...
schtasks /create /tn "n8n Runner Server" ^
  /tr "cmd.exe /c node C:\Users\ravia\Documents\n8n_runner\server.js" ^
  /sc onstart ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 3: n8n primary archive at 10:00AM ---
echo [3/4] Registering n8n primary archive task...
schtasks /create /tn "MEGA Reolink Archive" ^
  /tr "C:\Users\ravia\Documents\mega_archive.bat" ^
  /sc daily ^
  /st 10:00 ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Task 4: Backup archive at 10:15AM ---
echo [4/4] Registering backup archive task...
schtasks /create /tn "MEGA Reolink Archive Backup" ^
  /tr "C:\Users\ravia\Documents\mega_archive.bat" ^
  /sc daily ^
  /st 10:15 ^
  /rl highest ^
  /f
echo Done.
echo.

:: --- Verify all tasks registered ---
echo ============================================
echo Verifying registered tasks...
echo ============================================
schtasks /query /tn "n8n Auto Start"
schtasks /query /tn "n8n Runner Server"
schtasks /query /tn "MEGA Reolink Archive"
schtasks /query /tn "MEGA Reolink Archive Backup"

echo.
echo ============================================
echo All tasks registered successfully!
echo Reolink Archive Pipeline is ready.
echo ============================================
pause