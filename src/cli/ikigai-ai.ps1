# IKIGAI AI CLI Installer for Windows
# This script installs the IKIGAI CLI globally using pip.
# Usage (One-liner): 
# irm https://nguyenthanhduy220507.github.io/learn-cli-sdk/ikigai-ai.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting IKIGAI AI CLI Installation..." -ForegroundColor Cyan

# 1. Check for Python
try {
    $pythonVersion = python --version 2>$null
    Write-Host "✅ Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found. Please install Python 3.8+ from https://www.python.org/" -ForegroundColor Red
    exit 1
}

# 2. Check for Pip
try {
    $pipVersion = pip --version 2>$null
    Write-Host "✅ Found Pip" -ForegroundColor Green
} catch {
    Write-Host "❌ Pip not found. Please ensure Pip is installed with Python." -ForegroundColor Red
    exit 1
}

# 3. Install/Update IKIGAI CLI
Write-Host "📦 Installing IKIGAI AI CLI from GitHub..." -ForegroundColor Cyan
try {
    # Installing directly from the root of the repo
    pip install --upgrade "git+https://github.com/nguyenthanhduy220507/learn-cli-sdk.git"
    Write-Host "✅ Installation successful!" -ForegroundColor Green
} catch {
    Write-Host "❌ Installation failed. Please check your internet connection or git installation." -ForegroundColor Red
    exit 1
}

# 4. Verify Installation
Write-Host "🔍 Verifying installation..." -ForegroundColor Cyan
try {
    $version = ikigai --version
    Write-Host "✨ $version is ready to use!" -ForegroundColor Magenta
    Write-Host "`nTo get started, run:"
    Write-Host "  ikigai info" -ForegroundColor Yellow
    Write-Host "  ikigai login" -ForegroundColor Yellow
} catch {
    Write-Host "⚠️  Installation complete, but 'ikigai' command not found in PATH." -ForegroundColor Yellow
    Write-Host "Please restart your terminal or add the Python scripts folder to your PATH." -ForegroundColor Gray
}

Write-Host "`n🚀 Welcome to the future of AI infrastructure!" -ForegroundColor Green
