@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0\.."

set "HOST=127.0.0.1"
set "PORT=8890"
set "PYTHON_EXE=%CD%\env\python.exe"
set "API_FILE=%CD%\app\api.py"
set "UI_FILE=%CD%\ui\index.html"
set "API_URL=http://%HOST%:%PORT%/health"

echo ========================================================
echo   Edge TTS Portable
echo ========================================================

if not exist "%PYTHON_EXE%" goto :missing_setup
if not exist "%CD%\bin\ffmpeg.exe" goto :missing_setup

goto :skip_setup

:missing_setup
echo [ERRO] Ambiente nao configurado ou arquivos ausentes!
echo.
echo Por favor, feche esta janela e execute o arquivo "Instalar.bat"
echo para baixar os requisitos (Python e FFmpeg) automaticamente.
pause
exit /b 1

:skip_setup

:: Adicionar bin ao PATH para o FFmpeg
set "PATH=%CD%\bin;%PATH%"

if not exist "%CD%\output" mkdir "%CD%\output"

set "READY=0"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try { $r = Invoke-WebRequest -UseBasicParsing '%API_URL%' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
if not errorlevel 1 (
    set "READY=1"
    echo [1/3] API ja estava online.
    goto :open_ui
)

echo [1/3] Iniciando API FastAPI em nova janela...
start "Edge TTS API" cmd /k ""%PYTHON_EXE%" "%API_FILE%""

echo [2/3] Aguardando API responder...
for /L %%I in (1,1,40) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "try { $r = Invoke-WebRequest -UseBasicParsing '%API_URL%' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
    if not errorlevel 1 (
        set "READY=1"
        goto :open_ui
    )
    timeout /t 1 /nobreak >nul
)

:open_ui
if "%READY%"=="1" (
    echo [3/3] Abrindo interface...
    start "" "%UI_FILE%"
    echo.
    echo API pronta em http://%HOST%:%PORT%
    echo Docs em http://%HOST%:%PORT%/docs
) else (
    echo [AVISO] A API nao respondeu a tempo.
    echo Abra manualmente depois:
    echo   %UI_FILE%
    echo   http://%HOST%:%PORT%/docs
)

echo.
echo Para encerrar, feche a janela "Edge TTS API" ou execute stop.bat.
pause
