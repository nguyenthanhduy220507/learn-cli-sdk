@echo off
rem IKIGAI AI CLI Wrapper
rem Tự động pull bản mới nhất để đảm bảo máy khách luôn dùng version mới
docker pull ghcr.io/nguyenthanhduy220507/ikigai:latest > nul 2>&1

rem Chạy container: 
rem - Mount thư mục hiện tại của CMD vào /data trong container
rem - Chuyển Workspace (WORKDIR) của container sang /data
rem - Truyền API Key từ máy host vào container
docker run --rm -it ^
  -v "%cd%:/data" ^
  -w "/data" ^
  -e GEMINI_API_KEY=%GEMINI_API_KEY% ^
  ghcr.io/nguyenthanhduy220507/ikigai:latest %*
