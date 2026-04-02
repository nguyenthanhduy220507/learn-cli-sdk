#!/bin/bash
# ============================================================
# TEST CASE 1: Push code bình thường lên main / develop
# Kết quả mong đợi:
#   ✅ Job "test" PASS
#   ✅ Job "build-and-push" PASS → image được push với tag :latest
#   ⏭  Job "verify-release" SKIP (vì không phải git tag)
# ============================================================

set -e
echo "======================================"
echo " TEST CASE 1: Push branch bình thường"
echo "======================================"

# --- Bước 1: Chắc chắn đang ở nhánh main ---
git checkout main

# --- Bước 2: Thêm 1 thay đổi nhỏ (commit mới để trigger CI) ---
echo "# Updated at $(date)" >> README.md
git add README.md
git commit -m "chore: trigger CI test - push branch"

# --- Bước 3: Push lên GitHub → CI tự chạy ---
git push origin main

echo ""
echo "✅ Đã push! Vào GitHub → Actions để xem pipeline chạy."
echo "   URL: https://github.com/YOUR_ORG/YOUR_REPO/actions"
echo ""
echo "Kết quả mong đợi:"
echo "  Job 1 (test)            → ✅ PASS"
echo "  Job 2 (build-and-push)  → ✅ PASS, image tag: :latest :main"
echo "  Job 3 (verify-release)  → ⏭  SKIPPED"
echo ""
echo "Kiểm tra image đã được push:"
echo "  docker pull IMAGE="ghcr.io/YOUR_ORG/ikigai:latest"
docker pull $IMAGE
docker run --rm $IMAGE --help
docker run --rm $IMAGE hello --name "Test"
