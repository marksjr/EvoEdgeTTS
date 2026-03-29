@echo off
setlocal

echo Stopping Evo Edge TTS...
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8890" ^| findstr "LISTENING"') do (
    taskkill /PID %%P /T /F >nul 2>nul
)
echo Done.
pause
