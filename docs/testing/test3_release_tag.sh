#!/bin/bash
# ============================================================
# TEST CASE 3: Release version mới bằng git tag
# Kết quả mong đợi:
#   ✅ Job "test" PASS
#   ✅ Job "build-and-push" PASS → image push với NHIỀU tags
#   ✅ Job "verify-release" PASS → pull về test + check source leak
#
# Docker tags được tạo tự động từ tag v1.2.3:
#   :1.2.3   (exact version)
#   :1.2     (minor)
#   :1       (major)
#   :latest  (luôn trỏ đến bản mới nhất)
# ============================================================

set -e
echo "======================================"
echo " TEST CASE 3: Release với git tag"
echo "======================================"

# --- Cách A: Tạo tag thủ công (dev làm trực tiếp) ---

# Đảm bảo đang ở main và đã pull code mới nhất
git checkout main
git pull origin main

# Đọc version hiện tại
CURRENT_VERSION=$(python -c "
import re
with open('setup.py') as f:
    content = f.read()
m = re.search(r'version=[\"\']([\d.]+)[\"\'.]', content)
print(m.group(1) if m else '0.0.0')
")
echo "Version hiện tại: $CURRENT_VERSION"

# Tạo tag patch mới (ví dụ: 1.0.0 → 1.0.1)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
NEW_VERSION="$MAJOR.$MINOR.$((PATCH+1))"
NEW_TAG="v$NEW_VERSION"

echo "Version mới: $NEW_VERSION"
echo "Tag sẽ tạo: $NEW_TAG"

# Cập nhật version trong code
sed -i "s/version=\"$CURRENT_VERSION\"/version=\"$NEW_VERSION\"/" setup.py
sed -i "s/__version__ = \"$CURRENT_VERSION\"/__version__ = \"$NEW_VERSION\"/" ikigai/__init__.py

git add setup.py ikigai/__init__.py
git commit -m "chore: bump version to $NEW_VERSION"
git push origin main

# Tạo và push tag → trigger full CI/CD pipeline
git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
git push origin "$NEW_TAG"

echo ""
echo "✅ Tag $NEW_TAG đã được push!"
echo "   CI/CD pipeline đang chạy..."
echo "   URL: https://github.com/YOUR_ORG/YOUR_REPO/actions"
echo ""
echo "Kết quả mong đợi:"
echo "  Job 1 (test)            → ✅ PASS"
echo "  Job 2 (build-and-push)  → ✅ PASS"
echo "  Job 3 (verify-release)  → ✅ PASS (chạy vì có git tag)"
echo ""
echo "Docker tags được tạo:"
echo "  ghcr.io/YOUR_ORG/ikigai:$NEW_VERSION"
echo "  ghcr.io/YOUR_ORG/ikigai:$MAJOR.$MINOR"
echo "  ghcr.io/YOUR_ORG/ikigai:$MAJOR"
echo "  ghcr.io/YOUR_ORG/ikigai:latest"
echo ""
echo "Kiểm tra thủ công sau khi pipeline xong:"
echo "  docker pull ghcr.io/YOUR_ORG/ikigai:$NEW_VERSION"
echo "  docker run --rm ghcr.io/YOUR_ORG/ikigai:$NEW_VERSION info --json"

echo ""
echo "--- Cách B: Dùng workflow release.yml (khuyến nghị hơn) ---"
echo "  Vào GitHub → Actions → 'Release — Tạo version mới' → Run workflow"
echo "  Chọn: patch / minor / major"
echo "  Điền release notes"
echo "  → GitHub tự làm tất cả các bước trên!"
