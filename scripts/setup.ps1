$ErrorActionPreference = "Stop"

# Obter diretorio raiz
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$envDir = Join-Path $root "env"
$binDir = Join-Path $root "bin"

if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

# 1. Configurar Python Portatil (Embeddable)
if (-not (Test-Path (Join-Path $envDir "python.exe"))) {
    Write-Host "Baixando Python Portatil (Embeddable 3.11)..."
    $pyUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip"
    $pyZip = Join-Path $root "python.zip"
    
    Invoke-WebRequest -Uri $pyUrl -OutFile $pyZip
    
    Write-Host "Extraindo Python..."
    Expand-Archive -Path $pyZip -DestinationPath $envDir -Force
    Remove-Item $pyZip

    # Habilitar importacao de pacotes de terceiros (site-packages)
    $pthFile = Join-Path $envDir "python311._pth"
    $pthContent = Get-Content $pthFile
    $pthContent = $pthContent -replace '#import site', 'import site'
    Set-Content -Path $pthFile -Value $pthContent

    Write-Host "Baixando e instalando pip..."
    $getPip = Join-Path $envDir "get-pip.py"
    Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip
    
    $pythonExe = Join-Path $envDir "python.exe"
    & $pythonExe $getPip --no-warn-script-location
    Remove-Item $getPip

    Write-Host "Instalando dependencias (requirements.txt)..."
    & $pythonExe -m pip install -r requirements.txt --no-warn-script-location
}

# 2. Configurar FFmpeg
if (-not (Test-Path (Join-Path $binDir "ffmpeg.exe"))) {
    Write-Host "Baixando FFmpeg para suporte a arquivos WAV..."
    $ffmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    $ffmpegZip = Join-Path $root "ffmpeg.zip"
    
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegZip
    
    Write-Host "Extraindo FFmpeg..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ffmpegZip)
    $entry = $zip.Entries | Where-Object { $_.FullName -match "bin/ffmpeg\.exe$" } | Select-Object -First 1
    
    if ($entry) {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $binDir "ffmpeg.exe"), $true)
    } else {
        Write-Warning "Nao foi possivel encontrar ffmpeg.exe no arquivo zip."
    }
    
    $zip.Dispose()
    Remove-Item $ffmpegZip
}

Write-Host "Setup concluido com sucesso!"
