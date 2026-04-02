#!/bin/bash
# ikigai-runner.sh
# Script wrapper giúp team khác dùng CLI đơn giản hơn
# Thay vì gõ: docker run --rm registry.../ikigai:latest hello --name Alice
# Chỉ cần gõ: ./ikigai-runner.sh hello --name Alice

REGISTRY="registry.internal.company.com"
IMAGE="$REGISTRY/platform/ikigai:latest"

# Tự động pull image mới nhất mỗi lần chạy (có thể bỏ nếu muốn nhanh hơn)
docker pull "$IMAGE" --quiet

# Chạy CLI, truyền tất cả arguments vào
docker run --rm \
  -v "$(pwd)/data:/data" \
  "$IMAGE" "$@"
