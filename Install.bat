@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   Installer - Evo Edge TTS
echo ========================================================
echo.
echo This script will automatically download and configure:
echo  1. Portable Python
echo  2. FFmpeg (for WAV export)
echo  3. Required libraries
echo.
echo The process may take a few minutes depending on your internet connection.
echo.
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\scripts\setup.ps1"

if errorlevel 1 (
    echo.
    echo [ERROR] Installation failed.
) else (
    echo.
    echo [SUCCESS] Installation completed.
    echo You can now run start.bat to use Evo Edge TTS.
)
pause
