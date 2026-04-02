# <IKIGAI AI CLI> Installer for Windows
# GitHub Repo: https://github.com/nguyenthanhduy220507/learn-cli-sdk

$ErrorActionPreference = "Stop"

# 1. Variables
$INSTALL_DIR = Join-Path $HOME ".ikigai"
$IMAGE_NAME = "ghcr.io/nguyenthanhduy220507/learn-cli-sdk:latest"
$CMD_NAME = "ikigai.bat"

Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "   IKIGAI AI CLI SDK - Windows Installer" -ForegroundColor Cyan
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

# 2. Create Installation Directory
if (-not (Test-Path $INSTALL_DIR)) {
    Write-Host "[*] Creating installation directory at: $INSTALL_DIR" -ForegroundColor Gray
    New-Item -ItemType Directory -Path $INSTALL_DIR | Out-Null
}

# 3. Create ikigai.bat (Wrapper)
$BAT_PATH = Join-Path $INSTALL_DIR $CMD_NAME
$BAT_CONTENT = @"
@echo off
rem IKIGAI AI CLI Wrapper
rem Automatically pull the latest image
docker pull $IMAGE_NAME > nul 2>&1

docker run --rm -it ^
  -v "%cd%:/data" ^
  -w "/data" ^
  -e GEMINI_API_KEY=%GEMINI_API_KEY% ^
  $IMAGE_NAME %*
"@

Write-Host "[*] Creating wrapper file at: $BAT_PATH" -ForegroundColor Gray
Set-Content -Path $BAT_PATH -Value $BAT_CONTENT

# 4. Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    Write-Host "[*] Adding $INSTALL_DIR to Path environment variable..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$INSTALL_DIR", "User")
    Write-Host "[+] Successfully added to Path!" -ForegroundColor Green
} else {
    Write-Host "[i] Installation directory is already in Path." -ForegroundColor Gray
}

# 5. Pull the Image
Write-Host "[*] Pulling the latest CLI image from registry..." -ForegroundColor Cyan
docker pull $IMAGE_NAME

Write-Host "--------------------------------------------------" -ForegroundColor Green
Write-Host "✅ INSTALLATION COMPLETED!" -ForegroundColor Green
Write-Host "--------------------------------------------------" -ForegroundColor Green
Write-Host "NOTES:" -ForegroundColor Yellow
Write-Host "1. Please RESTART your Terminal for the 'ikigai' command to take effect."
Write-Host "2. Ensure Docker Desktop is running."
Write-Host "--------------------------------------------------"
