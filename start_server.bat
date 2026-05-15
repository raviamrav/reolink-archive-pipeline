@echo off
:: ============================================
:: Start Pipeline Services
:: Starts n8n and server.js if not already running
:: Scheduled daily at 9:50AM
:: ============================================

:: --- Check and start n8n ---
echo Checking n8n...
netstat -ano | findstr ":5678" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo n8n already running. Skipping.
) ELSE (
    echo Starting n8n...
    start /min "n8n Service" cmd /c "n8n start"
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
    start /min "n8n Runner" cmd /c "node C:\dev\portfolio\reolink-archive-pipeline\server.js"
    ::powershell -Command "Start-Process node -ArgumentList 'C:\dev\portfolio\reolink-archive-pipeline\server.js' -WindowStyle Hidden"
    timeout /t 5 /nobreak >nul
    echo server.js started.
)

echo All services ready.