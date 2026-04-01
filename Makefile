# Makefile - Các lệnh thường dùng trong quá trình dev & release

REGISTRY   = registry.internal.company.com
IMAGE_NAME = platform/mycli
VERSION    = 1.0.0
FULL_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
LATEST     = $(REGISTRY)/$(IMAGE_NAME):latest

# ─── DEV ────────────────────────────────────────────────────

## Chạy CLI trực tiếp trên máy (không qua Docker, cần có Python)
run:
	python -m mycli.main $(ARGS)

## Cài CLI vào máy local để dev
install-dev:
	pip install -e .

## Test thử các lệnh
test-local:
	mycli hello --name Developer
	mycli info
	mycli info --json

# ─── DOCKER ─────────────────────────────────────────────────

## Build Docker image
build:
	docker build -t $(FULL_IMAGE) -t $(LATEST) .

## Test image vừa build
test-docker:
	docker run --rm $(LATEST) hello --name Docker
	docker run --rm $(LATEST) info --json

## Xem source code có bị lộ trong image không
inspect-image:
	@echo "=== Kiểm tra nội dung image ==="
	docker run --rm --entrypoint sh $(LATEST) -c "find / -name '*.py' 2>/dev/null | head -20"

# ─── PUBLISH (chỉ CI/CD chạy) ───────────────────────────────

## Push lên registry nội bộ (không public!)
push:
	docker push $(FULL_IMAGE)
	docker push $(LATEST)

## Full release pipeline
release: build test-docker push
	@echo "✅ Released $(FULL_IMAGE)"

.PHONY: run install-dev test-local build test-docker inspect-image push release
