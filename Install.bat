@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   Installer - Edge TTS Portable
echo ========================================================
echo.
echo This script will automatically download and configure:
echo  1. Portable Python
echo  2. FFmpeg (to convert MP3 to WAV)
echo  3. Required libraries
echo.
echo The process may take a few minutes depending on your internet connection.
echo.
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\scripts\setup.ps1"

if errorlevel 1 (
    echo.
    echo [ERROR] An error occurred during installation.
) else (
    echo.
    echo [SUCCESS] Installation completed! 
    echo You can now run the "start.bat" file to use the system.
)
pause
