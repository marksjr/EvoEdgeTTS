@echo off
echo Encerrando a janela do Edge TTS Portable...
taskkill /FI "WINDOWTITLE eq Edge TTS API" /FI "IMAGENAME eq cmd.exe" /T /F >nul 2>nul
echo Finalizado.
pause
