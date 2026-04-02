# <IKIGAI AI CLI> Installer cho Windows
# Link GitHub: https://github.com/nguyenthanhduy220507/learn-cli-sdk

# Thiết lập hiển thị Unicode cho PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [Console]::OutputEncoding

$ErrorActionPreference = "Stop"

# 1. Cấu hình thông số
$INSTALL_DIR = Join-Path $HOME ".ikigai"
$IMAGE_NAME = "ghcr.io/nguyenthanhduy220507/ikigai:latest"
$CMD_NAME = "ikigai.bat"

Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "   IKIGAI AI CLI SDK - Windows Installer" -ForegroundColor Cyan
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

# 2. Tạo thư mục cài đặt
if (-not (Test-Path $INSTALL_DIR)) {
    Write-Host "[*] Tạo thư mục cài đặt tại: $INSTALL_DIR" -ForegroundColor Gray
    New-Item -ItemType Directory -Path $INSTALL_DIR | Out-Null
}

# 3. Tạo file ikigai.bat (Wrapper)
$BAT_PATH = Join-Path $INSTALL_DIR $CMD_NAME
$BAT_CONTENT = @"
@echo off
rem IKIGAI AI CLI Wrapper
rem Tự động pull bản mới nhất
docker pull $IMAGE_NAME > nul 2>&1

docker run --rm -it ^
  -v "%cd%:/data" ^
  -w "/data" ^
  -e GEMINI_API_KEY=%GEMINI_API_KEY% ^
  $IMAGE_NAME %*
"@

Write-Host "[*] Tạo file wrapper tại: $BAT_PATH" -ForegroundColor Gray
Set-Content -Path $BAT_PATH -Value $BAT_CONTENT

# 4. Thêm vào PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    Write-Host "[*] Đang thêm $INSTALL_DIR vào biến môi trường PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$INSTALL_DIR", "User")
    Write-Host "[+] Đã thêm vào PATH thành công!" -ForegroundColor Green
} else {
    Write-Host "[i] Thư mục cài đặt đã có trong PATH." -ForegroundColor Gray
}

# 5. Pull thử image
Write-Host "[*] Đang tải bản CLI mới nhất từ registry..." -ForegroundColor Cyan
docker pull $IMAGE_NAME

Write-Host "--------------------------------------------------" -ForegroundColor Green
Write-Host "✅ CÀI ĐẶT HOÀN TẤT!" -ForegroundColor Green
Write-Host "--------------------------------------------------" -ForegroundColor Green
Write-Host "LƯU Ý:" -ForegroundColor Yellow
Write-Host "1. Hãy TẮT và MỞ LẠI Terminal để lệnh 'ikigai' có hiệu lực."
Write-Host "2. Hãy đảm bảo Docker Desktop đang chạy."
Write-Host "--------------------------------------------------"
