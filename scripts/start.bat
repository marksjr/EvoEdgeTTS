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
echo   Evo Edge TTS
echo ========================================================

if not exist "%PYTHON_EXE%" goto :run_setup
if not exist "%CD%\bin\ffmpeg.exe" goto :run_setup
goto :skip_setup

:run_setup
echo [1/4] First run detected. Preparing the portable environment...
echo.
echo This will download Portable Python, FFmpeg and required libraries.
powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\scripts\setup.ps1"
if errorlevel 1 (
    echo.
    echo [ERROR] Automatic setup failed.
    echo Try running Install.bat manually and keep the window open until it finishes.
    pause
    exit /b 1
)

if not exist "%PYTHON_EXE%" (
    echo.
    echo [ERROR] Setup finished but python.exe was not found in env\.
    pause
    exit /b 1
)

if not exist "%CD%\bin\ffmpeg.exe" (
    echo.
    echo [ERROR] Setup finished but ffmpeg.exe was not found in bin\.
    pause
    exit /b 1
)

:skip_setup
set "PATH=%CD%\bin;%PATH%"
if not exist "%CD%\output" mkdir "%CD%\output"

echo [2/4] Checking current API status...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try { $r = Invoke-WebRequest -UseBasicParsing '%API_URL%' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
if not errorlevel 1 goto :open_ui

echo [3/4] Starting API...
start /b "" "%PYTHON_EXE%" "%API_FILE%"

echo [4/4] Waiting for the API to finish loading...
for /L %%I in (1,1,60) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "try { $r = Invoke-WebRequest -UseBasicParsing '%API_URL%' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
    if not errorlevel 1 goto :open_ui
    timeout /t 1 /nobreak >nul
)

echo.
echo [WARNING] The API did not respond in time.
echo Open the interface manually later:
echo   %UI_FILE%
pause
exit /b 1

:open_ui
echo.
echo Opening Evo Edge TTS in your browser...
start "" "%UI_FILE%"
echo.
echo Evo Edge TTS is ready.
echo Keep this window open while using the app.
echo Run stop.bat to close the API.
pause
