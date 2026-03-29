$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$distRoot = Join-Path $root "dist"
$portableName = "edge-tts-portable"
$portableDir = Join-Path $distRoot $portableName
$zipPath = Join-Path $distRoot "$portableName.zip"

if (Test-Path $portableDir) {
    Remove-Item -Recurse -Force $portableDir
}

if (-not (Test-Path $distRoot)) {
    New-Item -ItemType Directory -Path $distRoot | Out-Null
}

New-Item -ItemType Directory -Path $portableDir | Out-Null
New-Item -ItemType Directory -Path (Join-Path $portableDir "output") | Out-Null

$itemsToCopy = @(
    "app",
    "ui",
    "scripts",
    "requirements.txt",
    "start.bat",
    "stop.bat",
    "Install.bat"
)

foreach ($item in $itemsToCopy) {
    Copy-Item -Path (Join-Path $root $item) -Destination $portableDir -Recurse -Force
}

$readme = @"
Edge TTS Portable
=================

1. Run start.bat
2. Wait for the API to start and the environment to be configured automatically
3. The interface ui\index.html will open automatically
4. Local API: http://127.0.0.1:8890
5. Swagger Docs: http://127.0.0.1:8890/docs

Structure:
- app\api.py = FastAPI API
- ui\index.html = visual interface
- scripts\ = automation
- output\ = generated audio files

Notes:
- This distribution will automatically download portable Python and FFmpeg on the first run.
- Native MP3 is the recommended format for best fidelity.
"@

Set-Content -Path (Join-Path $portableDir "README.txt") -Value $readme -Encoding ASCII

if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Compress-Archive -Path (Join-Path $portableDir "*") -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "Portable generated at:"
Write-Host "  $portableDir"
Write-Host "Zip:"
Write-Host "  $zipPath"
