@echo off
setlocal
cd /d "%~dp0"
start "Evo Edge TTS" cmd /c call "%CD%\scripts\start.bat"
exit /b 0
