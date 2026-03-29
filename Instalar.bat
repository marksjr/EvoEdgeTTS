@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   Instalador - Edge TTS Portable
echo ========================================================
echo.
echo Este script vai baixar e configurar automaticamente:
echo  1. Python Portatil
echo  2. FFmpeg (para converter MP3 em WAV)
echo  3. Bibliotecas necessarias
echo.
echo O processo pode demorar alguns minutos dependendo da sua internet.
echo.
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\scripts\setup.ps1"

if errorlevel 1 (
    echo.
    echo [ERRO] Ocorreu um problema na instalacao.
) else (
    echo.
    echo [SUCESSO] Instalacao concluida! 
    echo Agora voce pode executar o arquivo "start.bat" para usar o sistema.
)
pause
