$ErrorActionPreference = "Stop"

function Download-File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    $curlExe = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curlExe) {
        & $curlExe.Source -L --fail --retry 3 --connect-timeout 20 -o $Destination $Url
        if ($LASTEXITCODE -eq 0 -and (Test-Path $Destination)) {
            return
        }
    }

    Invoke-WebRequest -Uri $Url -OutFile $Destination
}

# Get root directory
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$envDir = Join-Path $root "env"
$binDir = Join-Path $root "bin"

if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

# 1. Setup Portable Python (Embeddable)
if (-not (Test-Path (Join-Path $envDir "python.exe"))) {
    Write-Host "Downloading Portable Python (Embeddable 3.11)..."
    $pyUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip"
    $pyZip = Join-Path $root "python.zip"

    Download-File -Url $pyUrl -Destination $pyZip

    Write-Host "Extracting Python..."
    Expand-Archive -Path $pyZip -DestinationPath $envDir -Force
    Remove-Item $pyZip

    # Enable third-party packages (site-packages)
    $pthFile = Join-Path $envDir "python311._pth"
    $pthContent = Get-Content $pthFile
    $pthContent = $pthContent -replace '#import site', 'import site'
    Set-Content -Path $pthFile -Value $pthContent

    Write-Host "Downloading and installing pip..."
    $getPip = Join-Path $envDir "get-pip.py"
    Download-File -Url "https://bootstrap.pypa.io/get-pip.py" -Destination $getPip

    $pythonExe = Join-Path $envDir "python.exe"
    & $pythonExe $getPip --no-warn-script-location
    Remove-Item $getPip

    Write-Host "Installing dependencies (requirements.txt)..."
    & $pythonExe -m pip install -r requirements.txt --no-warn-script-location
}

# 2. Setup FFmpeg
if (-not (Test-Path (Join-Path $binDir "ffmpeg.exe"))) {
    Write-Host "Downloading FFmpeg for WAV file support..."
    $ffmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    $ffmpegZip = Join-Path $root "ffmpeg.zip"

    Download-File -Url $ffmpegUrl -Destination $ffmpegZip

    Write-Host "Extracting FFmpeg..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ffmpegZip)
    $entry = $zip.Entries | Where-Object { $_.FullName -match "bin/ffmpeg\.exe$" } | Select-Object -First 1

    if ($entry) {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $binDir "ffmpeg.exe"), $true)
    } else {
        Write-Warning "Could not find ffmpeg.exe in the zip file."
    }

    $zip.Dispose()
    Remove-Item $ffmpegZip
}

Write-Host "Setup completed successfully!"
