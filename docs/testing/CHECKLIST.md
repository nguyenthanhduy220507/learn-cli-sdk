# 🧪 Test CI/CD — Checklist tổng hợp

## Chuẩn bị trước khi test

```bash
# 1. Clone repo về (nếu chưa có)
git clone https://github.com/YOUR_ORG/YOUR_REPO.git
cd YOUR_REPO

# 2. Cấp quyền write cho Actions (chỉ làm 1 lần)
# GitHub → Settings → Actions → General
# → Workflow permissions → Read and write permissions ✅

# 3. Đảm bảo ghcr.io được enable
# GitHub → Settings → Packages → chọn repo visibility
```

---

## 4 Test cases & kết quả mong đợi

| Test | Trigger | Job 1 test | Job 2 build | Job 3 verify | Image được push? |
|------|---------|-----------|------------|-------------|-----------------|
| 1 — push main | `git push main` | ✅ | ✅ | ⏭ skip | ✅ `:latest` `:main` |
| 2 — pull request | tạo PR | ✅ | ✅ build only | ⏭ skip | ❌ không push |
| 3 — git tag | `git tag v1.x.x` | ✅ | ✅ | ✅ | ✅ `:1.x.x` `:1.x` `:1` `:latest` |
| 4A — syntax error | `git push main` | ❌ FAIL | ⏭ skip | ⏭ skip | ❌ |
| 4B — Dockerfile lỗi | `git push main` | ✅ | ❌ FAIL | ⏭ skip | ❌ |
| 4C — source lộ | `git tag v0.0.99` | ✅ | ✅ | ❌ FAIL | ✅ (nhưng unsafe!) |
| 4D — CLI crash | `git push main` | ❌ FAIL | ⏭ skip | ⏭ skip | ❌ |

---

## Cách đọc log trên GitHub Actions

```
GitHub → repo → tab Actions → click vào workflow run

Cấu trúc log:
  ▼ test                        ← Job 1
      Set up job
      Checkout code
      Set up Python
      Install dependencies
      Run CLI smoke test         ← Xem ở đây nếu 4A hoặc 4D fail
  ▼ build-and-push              ← Job 2
      Extract Docker metadata
      Login to GHCR
      Build and push             ← Xem ở đây nếu 4B fail
  ▼ verify-release              ← Job 3 (chỉ có khi push tag)
      Pull và test image
      Kiểm tra source không lộ   ← Xem ở đây nếu 4C fail
```

---

## Xác nhận image sau khi push

```bash
# Đặt biến cho tiện
REGISTRY="ghcr.io/YOUR_ORG/mycli"

# Test case 1 & 3 — confirm image tồn tại
docker pull $REGISTRY:latest
docker run --rm $REGISTRY:latest --help
docker run --rm $REGISTRY:latest info --json

# Test case 3 — confirm tất cả tags
docker pull $REGISTRY:1.0.1
docker pull $REGISTRY:1.0
docker pull $REGISTRY:1

# Test case 4C — confirm source lộ (dùng để học, KHÔNG làm production)
docker run --rm --entrypoint sh $REGISTRY:latest \
  -c "find / -name '*.py' 2>/dev/null | grep -v /usr"
# Kết quả đúng: không thấy mycli/main.py
# Kết quả sai:  /app/mycli/main.py ← lộ source!
```

---

## Rollback nhanh khi test xong

```bash
# Xóa tag test (nếu đã tạo)
git tag -d v0.0.99-test
git push origin :refs/tags/v0.0.99-test

# Hoàn tác commit gần nhất
git revert HEAD --no-edit
git push origin main

# Hoặc reset cứng (cẩn thận, mất commit)
git reset --hard HEAD~1
git push origin main --force
```

---

## Thứ tự test khuyến nghị

1. Chạy **test 1** trước → xác nhận pipeline cơ bản hoạt động
2. Chạy **test 2** → xem PR không push image
3. Chạy **test 4A** → xem pipeline biết phát hiện lỗi
4. Rollback 4A → chạy **test 3** → release version thật
5. Tùy chọn: **test 4B, 4C, 4D** để hiểu từng loại lỗi
