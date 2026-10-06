@echo off
:: ============================================
:: Start Pipeline Services
:: Starts n8n and server.js if not already running
:: Scheduled daily at 9:50AM
:: ============================================
SET "N8N_CMD=%APPDATA%\npm\n8n.cmd"
SET "NODE_CMD=%ProgramFiles%\nodejs\node.exe"
cd /d "%~dp0"

:: --- Check and start n8n ---
echo Checking n8n...
netstat -ano | findstr ":5678" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo n8n already running. Skipping.
) ELSE (
    echo Starting n8n...
    start /min "n8n Service" "%ComSpec%" /d /c call ""%N8N_CMD%" start"
    timeout /t 30 /nobreak >nul
    echo n8n started.
)

:: --- Check and start server.js ---
echo Checking server.js...
netstat -ano | findstr ":3000" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo server.js already running. Skipping.
) ELSE (
    echo Starting server.js...
    start /min "n8n Runner" "%ComSpec%" /d /c ""%NODE_CMD%" "%~dp0server.js""
    timeout /t 5 /nobreak >nul
    echo server.js started.
)

echo All services ready.