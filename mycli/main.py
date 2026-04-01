#!/usr/bin/env python3
import sys

def main():
    # LỖI CỐ TÌNH (KỊCH BẢN 4D): CLI bị crash ngay khi khởi động
    print("=== Đang khởi động IKIGAI AI CLI... ===")
    raise RuntimeError("LỖI NGHIÊM TRỌNG: Script bị crash do lỗi logic giả lập!")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
