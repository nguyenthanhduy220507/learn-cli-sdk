# ============================================================
# STAGE 1: BUILD
# Giai đoạn này có source code, nhưng sẽ KHÔNG được ship
# ============================================================
FROM python:3.11-slim AS builder

WORKDIR /build

# Copy source code vào builder (chỉ tồn tại ở stage này)
COPY . .

# Cài đặt build tools
RUN pip install --upgrade pip build

# Build thành file .whl (wheel) - đây là file binary đã đóng gói
# File .whl KHÔNG chứa source code thô, khó reverse engineer
RUN python -m build --wheel --outdir /dist


# ============================================================
# STAGE 2: RUNTIME (image cuối cùng ship cho team khác)
# Giai đoạn này KHÔNG có source code, chỉ có wheel đã compiled
# ============================================================
FROM python:3.11-slim AS runtime

WORKDIR /app

# Chỉ copy file .whl từ stage builder (không copy source)
COPY --from=builder /dist/*.whl /tmp/

# Cài CLI từ wheel
RUN pip install /tmp/*.whl && rm /tmp/*.whl

# Tạo user non-root cho bảo mật
RUN useradd -m cliuser
USER cliuser

# Khi chạy container mà không truyền lệnh, hiện help
ENTRYPOINT ["ikigai"]
CMD ["--help"]
