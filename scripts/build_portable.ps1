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
    "Instalar.bat"
)

foreach ($item in $itemsToCopy) {
    Copy-Item -Path (Join-Path $root $item) -Destination $portableDir -Recurse -Force
}

$readme = @"
Edge TTS Portable
=================

1. Execute start.bat
2. Aguarde a API subir e o ambiente ser configurado automaticamente
3. A interface ui\index.html abrira automaticamente
4. API local: http://127.0.0.1:8890
5. Docs Swagger: http://127.0.0.1:8890/docs

Estrutura:
- app\api.py = API FastAPI
- ui\index.html = interface visual
- scripts\ = automacao
- output\ = audios gerados

Observacoes:
- Esta distribuicao baixara o Python portatil e FFmpeg automaticamente na primeira execucao.
- O formato recomendado para melhor fidelidade e MP3 nativo.
"@

Set-Content -Path (Join-Path $portableDir "README.txt") -Value $readme -Encoding ASCII

if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Compress-Archive -Path (Join-Path $portableDir "*") -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "Portable gerado em:"
Write-Host "  $portableDir"
Write-Host "Zip:"
Write-Host "  $zipPath"
