#!/bin/bash
# ============================================================
# TEST CASE 4: Giả lập lỗi để xem pipeline fail đúng chỗ
#
# 4A - Lỗi syntax Python    → Job "test" FAIL
# 4B - Lỗi Dockerfile       → Job "build-and-push" FAIL
# 4C - Source code bị lộ    → Job "verify-release" FAIL
# 4D - CLI crash khi chạy   → Job "test" FAIL tại smoke test
# ============================================================

echo "Chọn lỗi muốn giả lập:"
echo "  4A) Syntax error Python"
echo "  4B) Dockerfile lỗi"
echo "  4C) Source code lộ trong image"
echo "  4D) CLI crash khi chạy"
echo ""
echo "Xem từng kịch bản bên dưới:"

# ============================================================
# KỊCH BẢN 4A: Lỗi syntax Python → Job TEST fail
# ============================================================
scenario_4A() {
  echo ""
  echo "=== 4A: Giả lập syntax error Python ==="

  # Thêm syntax lỗi vào main.py
  cat >> ikigai/main.py << 'EOF'

# LỖI CỐ TÌNH: dấu ngoặc thiếu
def broken_function(
EOF

  git add ikigai/main.py
  git commit -m "test(4A): intentional syntax error — expect CI fail at test job"
  git push origin main

  echo "Kết quả mong đợi:"
  echo "  Job 1 (test)           → ❌ FAIL — pip install lỗi hoặc ikigai crash"
  echo "  Job 2 (build-and-push) → ⏭  SKIPPED (vì job 1 fail)"
  echo "  Job 3 (verify-release) → ⏭  SKIPPED"
  echo ""
  echo "Sau khi xem log, rollback lại:"
  echo "  git revert HEAD && git push origin main"
}

# ============================================================
# KỊCH BẢN 4B: Lỗi Dockerfile → Job BUILD-AND-PUSH fail
# ============================================================
scenario_4B() {
  echo ""
  echo "=== 4B: Giả lập Dockerfile lỗi ==="

  # Backup Dockerfile
  cp Dockerfile Dockerfile.bak

  # Tạo Dockerfile lỗi: câu lệnh không tồn tại
  cat > Dockerfile << 'EOF'
FROM python:3.11-slim AS builder
WORKDIR /build
COPY . .
RUN pip install build
RUN python -m build --wheel --outdir /dist

FROM python:3.11-slim AS runtime
WORKDIR /app
COPY --from=builder /dist/*.whl /tmp/
# LỖI CỐ TÌNH: lệnh không tồn tại
RUN this-command-does-not-exist
RUN pip install /tmp/*.whl && rm /tmp/*.whl
ENTRYPOINT ["ikigai"]
CMD ["--help"]
EOF

  git add Dockerfile
  git commit -m "test(4B): broken Dockerfile — expect CI fail at build job"
  git push origin main

  echo "Kết quả mong đợi:"
  echo "  Job 1 (test)           → ✅ PASS (không liên quan đến Dockerfile)"
  echo "  Job 2 (build-and-push) → ❌ FAIL — docker build lỗi tại RUN"
  echo "  Job 3 (verify-release) → ⏭  SKIPPED"
  echo ""
  echo "Rollback:"
  echo "  cp Dockerfile.bak Dockerfile"
  echo "  git add Dockerfile && git commit -m 'fix: restore Dockerfile'"
  echo "  git push origin main"
}

# ============================================================
# KỊCH BẢN 4C: Source code lộ trong image → Job VERIFY fail
# ============================================================
scenario_4C() {
  echo ""
  echo "=== 4C: Giả lập source code bị lộ trong Docker image ==="

  # Backup Dockerfile
  cp Dockerfile Dockerfile.bak

  # Tạo Dockerfile 1 stage (KHÔNG dùng multi-stage)
  # → source code nằm thẳng trong image!
  cat > Dockerfile << 'EOF'
# Dockerfile CỐ TÌNH sai: không dùng multi-stage
# → source code nằm trong image
FROM python:3.11-slim
WORKDIR /app

# Copy toàn bộ source vào image (RỦI RO!)
COPY . .

RUN pip install --upgrade pip && pip install -e .

ENTRYPOINT ["ikigai"]
CMD ["--help"]
EOF

  git add Dockerfile
  git commit -m "test(4C): single-stage build (source exposed) — expect verify job fail"

  # Cần push tag để trigger verify-release job
  git tag -a "v0.0.99-test" -m "Test tag for scenario 4C"
  git push origin main
  git push origin v0.0.99-test

  echo "Kết quả mong đợi:"
  echo "  Job 1 (test)           → ✅ PASS"
  echo "  Job 2 (build-and-push) → ✅ PASS (build thành công, nhưng image chứa source)"
  echo "  Job 3 (verify-release) → ❌ FAIL — tìm thấy main.py trong image!"
  echo ""
  echo "  Log sẽ in: '❌ SOURCE CODE BỊ LỘ! Kiểm tra lại Dockerfile!'"
  echo ""
  echo "Rollback:"
  echo "  cp Dockerfile.bak Dockerfile"
  echo "  git add Dockerfile && git commit -m 'fix: restore multi-stage Dockerfile'"
  echo "  git push origin main"
  echo "  git tag -d v0.0.99-test && git push origin :refs/tags/v0.0.99-test"
}

# ============================================================
# KỊCH BẢN 4D: CLI crash khi chạy → smoke test fail
# ============================================================
scenario_4D() {
  echo ""
  echo "=== 4D: Giả lập CLI crash khi chạy ==="

  # Backup main.py
  cp ikigai/main.py ikigai/main.py.bak

  # Thêm bug: main() raise Exception ngay lập tức
  cat > ikigai/main.py << 'EOF'
#!/usr/bin/env python3
import argparse, sys

def main():
    # LỖI CỐ TÌNH: crash ngay khi chạy
    raise RuntimeError("Lỗi nghiêm trọng giả lập!")

if __name__ == "__main__":
    main()
EOF

  git add ikigai/main.py
  git commit -m "test(4D): CLI crashes on startup — expect CI fail at smoke test"
  git push origin main

  echo "Kết quả mong đợi:"
  echo "  Job 1 (test) → ❌ FAIL tại bước 'Run CLI smoke test'"
  echo "  Log sẽ in: 'RuntimeError: Lỗi nghiêm trọng giả lập!'"
  echo ""
  echo "Rollback:"
  echo "  cp ikigai/main.py.bak ikigai/main.py"
  echo "  git add ikigai/main.py && git commit -m 'fix: restore working main.py'"
  echo "  git push origin main"
}

# --- Chạy kịch bản theo tham số ---
case "$1" in
  4A) scenario_4A ;;
  4B) scenario_4B ;;
  4C) scenario_4C ;;
  4D) scenario_4D ;;
  *)
    echo "Dùng: bash test4_failure_cases.sh [4A|4B|4C|4D]"
    echo "Ví dụ: bash test4_failure_cases.sh 4A"
    ;;
esac
