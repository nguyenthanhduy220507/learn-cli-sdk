# 🛠 CLI SDK Demo — Hướng dẫn Step by Step

> **Mục tiêu**: Hiểu toàn bộ quy trình từ "viết CLI bằng Python" → "đóng gói Docker" → "phân phối nội bộ không lộ source" → "team khác dùng được"

---

## 📐 Tổng quan kiến trúc

```
┌─────────────────────────────────────────────────────────────┐
│                    PLATFORM TEAM (bạn)                      │
│                                                             │
│  1. Viết code CLI   →   2. Build Docker   →   3. Push lên  │
│     (Python)              (2-stage build)       Registry    │
└──────────────────────────────────┬──────────────────────────┘
                                   │ Image (không có source)
                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                  INTERNAL REGISTRY                          │
│         registry.internal.company.com                       │
│         (GitLab Registry / Harbor / AWS ECR...)             │
└──────────────────────────────────┬──────────────────────────┘
                                   │ docker pull
                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                  TEAM KHÁC (consumer)                       │
│                                                             │
│  4. Pull image  →  5. Chạy CLI  →  6. Dùng như binary      │
│  (không thấy source code)                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Cấu trúc project

```
cli-sdk-demo/
├── mycli/
│   ├── __init__.py       # Package marker
│   └── main.py           # Logic CLI chính
├── Dockerfile            # 2-stage build (quan trọng nhất!)
├── docker-compose.yml    # Dành cho consumer dùng
├── Makefile              # Shortcuts cho dev team
├── mycli-runner.sh       # Script wrapper cho consumer
├── setup.py              # Cấu hình đóng gói Python
└── .dockerignore         # Loại trừ file không cần thiết
```

---

## 🚀 FLOW 1 — Build CLI Tool cơ bản (Python)

### Bước 1.1: Hiểu cấu trúc CLI

File `mycli/main.py` là trái tim của tool:

```python
# argparse giúp tạo CLI với các subcommand
parser = argparse.ArgumentParser(prog="mycli")
subparsers = parser.add_subparsers(dest="command")

# Mỗi subcommand là một "lệnh" riêng
subparsers.add_parser("hello")   # mycli hello
subparsers.add_parser("info")    # mycli info
subparsers.add_parser("process") # mycli process
```

### Bước 1.2: Chạy thử trên máy local

```bash
# Cài vào máy ở chế độ "editable" (dev mode)
pip install -e .

# Test các lệnh
mycli --help
mycli hello --name "Alice"
mycli info
mycli info --json
mycli process --input ./data.csv --output ./results
```

### Bước 1.3: Hiểu setup.py — điểm quan trọng

```python
entry_points={
    "console_scripts": [
        "mycli=mycli.main:main",  # gõ "mycli" → gọi hàm main() trong mycli/main.py
    ],
}
```

Đây là cách Python đăng ký lệnh CLI với hệ thống. Sau khi `pip install`, gõ `mycli` từ bất kỳ đâu đều chạy được.

---

## 🐳 FLOW 2 — Đóng gói thành Docker Image

### Khái niệm quan trọng: Multi-stage Build

Đây là **kỹ thuật chính** để không lộ source code:

```
Stage 1 (builder):          Stage 2 (runtime):
┌────────────────┐          ┌────────────────┐
│ Source code    │          │ KHÔNG có       │
│ setup.py       │  build   │ source code!   │
│ mycli/         │ ──────►  │                │
│                │          │ Chỉ có .whl    │
│ → tạo ra .whl  │          │ (compiled)     │
└────────────────┘          └────────────────┘
    (bị bỏ đi)                  (ship cái này)
```

### Đọc Dockerfile từng phần:

```dockerfile
# === STAGE 1: Có source, dùng để BUILD, không ship ===
FROM python:3.11-slim AS builder
COPY . .                          # copy source vào đây
RUN python -m build --wheel       # biến source → file .whl

# === STAGE 2: Image cuối, KHÔNG có source ===
FROM python:3.11-slim AS runtime
COPY --from=builder /dist/*.whl /tmp/   # chỉ lấy .whl từ stage 1
RUN pip install /tmp/*.whl              # cài từ .whl
# → source code không bao giờ vào image này!
```

### Bước 2.1: Build image

```bash
docker build -t mycli:latest .

# Hoặc dùng Makefile:
make build
```

### Bước 2.2: Test image

```bash
# Chạy lệnh hello
docker run --rm mycli:latest hello --name Docker

# Chạy lệnh info
docker run --rm mycli:latest info --json

# Xem help
docker run --rm mycli:latest --help
```

### Bước 2.3: Kiểm tra source có bị lộ không?

```bash
# Chui vào trong image và tìm file .py
docker run --rm --entrypoint sh mycli:latest \
  -c "find / -name '*.py' 2>/dev/null"

# Kết quả mong đợi: CHỈ thấy các file của Python runtime,
# KHÔNG thấy mycli/main.py hay setup.py của bạn!
```

---

## 🏢 FLOW 3 — Phân phối nội bộ (không public source)

### Bước 3.1: Hiểu về Internal Registry

Registry là kho lưu Docker images, giống như npm registry nhưng cho Docker:

```
Public registry:   Docker Hub (hub.docker.com) — ai cũng thấy
Private registry:  GitLab Registry, Harbor, AWS ECR — chỉ nội bộ
```

Công ty thường dùng 1 trong:
- **GitLab Container Registry**: `registry.gitlab.company.com`
- **Harbor**: `harbor.company.com`
- **AWS ECR**: `123456.dkr.ecr.ap-southeast-1.amazonaws.com`

### Bước 3.2: Tag và Push image

```bash
# Đặt tên image theo convention của công ty
docker tag mycli:latest registry.internal.company.com/platform/mycli:1.0.0
docker tag mycli:latest registry.internal.company.com/platform/mycli:latest

# Login vào registry (chỉ cần 1 lần, hoặc CI/CD tự làm)
docker login registry.internal.company.com

# Push lên registry
docker push registry.internal.company.com/platform/mycli:1.0.0
docker push registry.internal.company.com/platform/mycli:latest
```

### Bước 3.3: Versioning strategy

```
mycli:latest    → luôn trỏ đến bản mới nhất (cho dev)
mycli:1.0.0     → version cụ thể (cho production, stable)
mycli:1.0       → minor version (tự cập nhật patch)
```

### Bước 3.4: Tích hợp CI/CD (GitLab CI ví dụ)

```yaml
# .gitlab-ci.yml
build-and-push:
  stage: release
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  only:
    - tags  # chỉ release khi tạo git tag
```

Khi dev push tag `v1.0.0` lên Git → CI tự build và push image.
**Team khác không bao giờ thấy source code!**

---

## 👥 FLOW 4 — Cách team khác pull và dùng

### Cách 1: Docker run trực tiếp (đơn giản nhất)

```bash
# Team khác chỉ cần chạy lệnh này
docker run --rm \
  registry.internal.company.com/platform/mycli:latest \
  hello --name "Team Backend"

# Không cần cài Python, không cần source code!
```

### Cách 2: Dùng wrapper script (tiện hơn)

Bạn cung cấp file `mycli-runner.sh` cho các team:

```bash
# Team khác tải về script
curl -O https://internal-docs.company.com/tools/mycli-runner.sh
chmod +x mycli-runner.sh

# Dùng như binary bình thường
./mycli-runner.sh hello --name Alice
./mycli-runner.sh info --json
./mycli-runner.sh process --input ./data.csv
```

### Cách 3: Docker Compose (cho workflow phức tạp)

```bash
# Team khác tải docker-compose.yml về
curl -O https://internal-docs.company.com/tools/docker-compose.yml

# Chạy
docker compose run mycli hello --name Alice
docker compose run mycli process --input /data/input.csv
```

### Cách 4: Alias trong shell (tiện nhất cho daily use)

Team khác thêm vào `.bashrc` hoặc `.zshrc`:

```bash
alias mycli='docker run --rm -v $(pwd)/data:/data registry.internal.company.com/platform/mycli:latest'

# Sau đó dùng như lệnh bình thường:
mycli hello --name Alice
mycli info
```

---

## 🔍 So sánh: Tại sao Docker thay vì publish PyPI?

| Tiêu chí              | PyPI (public)     | PyPI (private)    | Docker (private)      |
|-----------------------|-------------------|-------------------|-----------------------|
| Source code lộ không? | ✅ Lộ (wheel)     | ⚠️ Lộ (wheel)    | ❌ Không lộ           |
| Team khác cần Python? | ✅ Cần            | ✅ Cần            | ❌ Không cần          |
| Dependency conflict?  | ✅ Có thể xảy ra  | ✅ Có thể xảy ra  | ❌ Isolated hoàn toàn |
| Setup phức tạp?       | Đơn giản          | Vừa               | Vừa (cần Docker)      |
| Versioning            | Tốt               | Tốt               | Rất tốt               |

**Docker image là lựa chọn phù hợp nhất** khi:
- Không muốn lộ source code
- Muốn team khác không phụ thuộc vào Python version
- Muốn đảm bảo môi trường chạy nhất quán

---

## 📋 Checklist trước khi join dự án thực tế

- [ ] Hỏi anh Lead: Registry nội bộ là gì? (GitLab / Harbor / ECR?)
- [ ] Hỏi: Convention đặt tên image như thế nào?
- [ ] Hỏi: CI/CD pipeline đang dùng gì? (GitLab CI / Jenkins / GitHub Actions?)
- [ ] Tìm hiểu: Các team consumer cần setup gì để pull được image?
- [ ] Xác nhận: Python version cần hỗ trợ?
- [ ] Xem code hiện tại của team để hiểu các command cần export

---

## 🧠 Tóm tắt toàn bộ flow

```
1. Viết CLI (Python + argparse)
       ↓
2. setup.py → định nghĩa entry_point "mycli"
       ↓
3. Dockerfile (multi-stage):
   Stage 1: source → .whl
   Stage 2: cài .whl (không có source)
       ↓
4. docker build → image
       ↓
5. docker push → internal registry
       ↓
6. Team khác: docker pull → docker run mycli <command>
```
