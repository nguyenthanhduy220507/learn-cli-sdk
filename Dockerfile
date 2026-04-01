# ============================================================
# KỊCH BẢN 4C: Dockerfile CHỈ CÓ 1 STAGE (SAI LẦM BẢO MẬT)
# ============================================================
FROM python:3.11-slim

WORKDIR /app

# COPY THẲNG TOÀN BỘ SOURCE CODE VÀO IMAGE (LỖI NẰM Ở ĐÂY!)
COPY . .

# Cài đặt trực tiếp từ source
RUN pip install -e .

# Tạo user non-root
RUN useradd -m cliuser
USER cliuser

# Entrypoint
ENTRYPOINT ["mycli"]
CMD ["--help"]
