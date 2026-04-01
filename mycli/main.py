#!/usr/bin/env python3
"""
mycli - Demo CLI SDK
Đây là tool CLI mà team bạn sẽ build và phân phối cho các team khác.
"""

import argparse
import json
import sys
from datetime import datetime


def cmd_hello(args):
    """Lệnh chào hỏi cơ bản"""
    name = args.name or "World"
    print(f"👋 Hello, {name}! Đây là mycli v1.0.0")


def cmd_info(args):
    """Hiển thị thông tin hệ thống"""
    info = {
        "tool": "mycli",
        "version": "1.0.0",
        "python": sys.version,
        "timestamp": datetime.now().isoformat(),
        "team": "Platform Team",
    }
    if args.json:
        print(json.dumps(info, indent=2))
    else:
        for key, value in info.items():
            print(f"  {key:12} : {value}")


def cmd_process(args):
    """Xử lý dữ liệu demo"""
    print(f"⚙️  Đang xử lý file: {args.input}")
    print(f"📁 Output sẽ lưu tại: {args.output}")
    # Giả lập xử lý
    print("✅ Hoàn thành!")


def main():
    parser = argparse.ArgumentParser(
        prog="mycli",
        description="🛠  mycli - Internal CLI SDK by Platform Team",
    )
    subparsers = parser.add_subparsers(dest="command", help="Các lệnh có sẵn")

    # Command: hello
    p_hello = subparsers.add_parser("hello", help="Chào hỏi")
    p_hello.add_argument("--name", help="Tên người dùng")

    # Command: info
    p_info = subparsers.add_parser("info", help="Thông tin hệ thống")
    p_info.add_argument("--json", action="store_true", help="Output dạng JSON")

    # Command: process
    p_process = subparsers.add_parser("process", help="Xử lý dữ liệu")
    p_process.add_argument("--input", required=True, help="File đầu vào")
    p_process.add_argument("--output", default="./output", help="Thư mục đầu ra")

    args = parser.parse_args()

    if args.command == "hello":
        cmd_hello(args)
    elif args.command == "info":
        cmd_info(args)
    elif args.command == "process":
        cmd_process(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
