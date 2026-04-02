---

## 🤖 FLOW 5 — GitHub Actions CI/CD (tự động hóa hoàn toàn)

### Tổng quan 2 workflow

```
.github/workflows/
├── ci-cd.yml      # Tự động chạy mỗi khi push code
└── release.yml    # Tạo version mới (chạy thủ công)
```

### ci-cd.yml — Chạy tự động khi push

**3 jobs nối tiếp nhau:**

```
push code  →  [test]  →  [build-and-push]  →  [verify-release]*
                 ↓              ↓                      ↓
           ikigai --help    docker buildx          docker pull
           ikigai hello     multi-platform         test image
           ikigai info      push to ghcr.io        check source leak
                           cache layers

* verify-release chỉ chạy khi tạo git tag
```

**Tags được tạo tự động:**

| Git action            | Docker tags tạo ra                        |
|-----------------------|-------------------------------------------|
| push lên `main`       | `latest`, `main`                          |
| push lên `develop`    | `develop`                                 |
| tạo tag `v1.2.3`      | `1.2.3`, `1.2`, `1`, `latest`             |
| mở Pull Request       | `pr-42` (chỉ build, không push)           |

### release.yml — Tạo version mới (thủ công)

Vào GitHub → Actions → "Release" → "Run workflow" → chọn `patch/minor/major`.

Workflow tự động:
1. Đọc version hiện tại từ `setup.py`
2. Tính version mới (1.0.0 → 1.0.1)
3. Cập nhật `setup.py` và `ikigai/__init__.py`
4. Commit + push
5. Tạo git tag `v1.0.1`
6. Tạo GitHub Release với hướng dẫn docker pull

### Setup lần đầu (chỉ cần làm 1 lần)

```bash
# 1. Push code lên GitHub
git init
git add .
git commit -m "feat: initial CLI SDK"
git remote add origin https://github.com/YOUR_ORG/ikigai.git
git push -u origin main

# 2. Vào Settings → Actions → General
#    → Workflow permissions → Read and write permissions ✅

# 3. Vào Settings → Packages
#    → Đảm bảo ghcr.io được enable (mặc định là có)

# 4. Không cần thêm secret gì cả!
#    GITHUB_TOKEN được tạo tự động bởi GitHub Actions
```

### Cách team khác dùng image từ ghcr.io

```bash
# Pull image công khai (nếu repo public)
docker pull ghcr.io/YOUR_ORG/ikigai:latest

# Nếu repo private, cần login trước
echo $GITHUB_PAT | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/YOUR_ORG/ikigai:latest
```
