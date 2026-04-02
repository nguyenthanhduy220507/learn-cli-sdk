#!/bin/bash
# ============================================================
# TEST CASE 2: Tạo Pull Request vào main
# Kết quả mong đợi:
#   ✅ Job "test" PASS
#   ✅ Job "build-and-push" PASS → build nhưng KHÔNG push image
#   ⏭  Job "verify-release" SKIP
#
# Mục đích: Review code an toàn — CI kiểm tra nhưng
#           không làm "ô nhiễm" registry bằng image chưa merge
# ============================================================

set -e
echo "======================================"
echo " TEST CASE 2: Pull Request vào main"
echo "======================================"

# --- Bước 1: Tạo branch feature mới ---
BRANCH="feature/add-version-command-$(date +%s)"
git checkout -b "$BRANCH"

# --- Bước 2: Thêm tính năng mới (ví dụ: thêm command "version") ---
cat >> ikigai/main.py << 'EOF'

def cmd_version(args):
    """Hiển thị version"""
    from ikigai import __version__
    print(f"ikigai v{__version__}")
EOF

# Thêm subcommand version vào parser trong main()
# (Thực tế bạn sẽ edit file tay hoặc dùng IDE)

git add ikigai/main.py
git commit -m "feat: add version command"

# --- Bước 3: Push branch lên GitHub ---
git push origin "$BRANCH"

echo ""
echo "✅ Branch đã được push!"
echo ""
echo "Bước tiếp theo - tạo PR trên GitHub:"
echo "  1. Vào: https://github.com/YOUR_ORG/YOUR_REPO/compare/$BRANCH"
echo "  2. Click 'Create pull request'"
# 3. Quan sát CI chạy trong tab 'Checks' của PR

echo ""
echo "Kết quả mong đợi:"
echo "  Job 1 (test)            → ✅ PASS"
#  Job 2 (build-and-push)  → ✅ BUILD thành công nhưng KHÔNG push
#  Job 3 (verify-release)  → ⏭  SKIPPED

echo ""
echo "Cách xác nhận image KHÔNG bị push khi là PR:"
echo "  # Lệnh này sẽ FAIL nếu image không tồn tại → đúng như mong đợi"
IMAGE="ghcr.io/YOUR_ORG/ikigai:pr-1"
echo "  docker pull $IMAGE"
