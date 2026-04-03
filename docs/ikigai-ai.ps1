# IKIGAI AI CLI Installer for Windows
# This script installs the IKIGAI CLI globally using pip.
# Usage (One-liner): 
# irm https://nguyenthanhduy220507.github.io/learn-cli-sdk/ikigai-ai.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "Starting IKIGAI AI CLI Installation..." -ForegroundColor Cyan

# 1. Check for Python
try {
    $pythonVersion = python --version 2>$null
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python not found. Please install Python 3.8+ from https://www.python.org/" -ForegroundColor Red
    exit 1
}

# 2. Check for Pip
try {
    $pipVersion = pip --version 2>$null
    Write-Host "Found Pip" -ForegroundColor Green
} catch {
    Write-Host "Pip not found. Please ensure Pip is installed with Python." -ForegroundColor Red
    exit 1
}

# 3. Install/Update IKIGAI CLI
Write-Host "Preparing clean installation..." -ForegroundColor Cyan
try {
    # Force uninstall old version if exists to avoid conflicts
    pip uninstall -y ikigai 2>$null
    
    Write-Host "Downloading and installing IKIGAI AI CLI from GitHub..." -ForegroundColor Cyan
    # Installing directly from the root of the repo with no-cache to ensure latest code
    pip install --upgrade --no-cache-dir --force-reinstall "git+https://github.com/nguyenthanhduy220507/learn-cli-sdk.git"
    Write-Host "Installation successful!" -ForegroundColor Green
} catch {
    Write-Host "Installation failed. Please check your internet connection or git installation." -ForegroundColor Red
    exit 1
}

# 4. Verify Installation
Write-Host "🔍 Verifying installation..." -ForegroundColor Cyan
try {
    # Refresh path for current session if possible (optional but helpful)
    $version = ikigai --version
    Write-Host "$version is ready to use!" -ForegroundColor Magenta
    
    Write-Host "`nSetup Complete! Follow these steps to get started:" -ForegroundColor Magenta
    Write-Host "1. Configure connection to your Server:" -ForegroundColor White
    Write-Host "   ikigai config server http://172.16.111.225:8000" -ForegroundColor Yellow
    Write-Host "2. Verify system status:" -ForegroundColor White
    Write-Host "   ikigai info" -ForegroundColor Yellow
    Write-Host "3. Authenticate:" -ForegroundColor White
    Write-Host "   ikigai login" -ForegroundColor Yellow
} catch {
    Write-Host "Installation complete, but 'ikigai' command not found in PATH." -ForegroundColor Yellow
    Write-Host "Please restart your terminal or add the Python scripts folder to your PATH manually." -ForegroundColor Gray
}

Write-Host "`nWelcome to the future of AI infrastructure!" -ForegroundColor Green
