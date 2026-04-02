#!/usr/bin/env python3
"""
ikigai - IKIGAI AI CLI SDK
"""

import argparse
import json
import sys
import os
from datetime import datetime

if sys.stdout.encoding.lower() != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except AttributeError:
        pass

from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.table import Table
from rich.align import Align

console = Console()

# Stylized ASCII Art for IKIGAI AI
IKIGAI_ASCII = """
 ██╗██╗  ██╗██╗ ██████╗  █████╗ ██╗     █████╗ ██╗
 ██║██║ ██╔╝██║██╔════╝ ██╔══██╗██║    ██╔══██╗██║
 ██║█████╔╝ ██║██║  ███╗███████║██║    ███████║██║
 ██║██╔═██╗ ██║██║   ██║██╔══██║██║    ██╔══██║██║
 ██║██║  ██╗██║╚██████╔╝██║  ██║██║    ██║  ██║██║
 ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝    ╚═╝  ╚═╝╚═╝
"""

def show_splash():
    """Hiển thị splash screen phong cách IKIGAI AI"""
    # Header box similar to Claude Code
    header_text = Text("Welcome to IKIGAI AI", style="bold white on #afca31")
    console.print(Align.center(Panel(header_text, border_style="#afca31", padding=(0, 2))))
    
    # Large Logo
    logo = Text(IKIGAI_ASCII, style="#afca31")
    console.print(Align.center(logo))
    
    console.print(Align.center(Text("Press Enter to continue...", style="dim italic blue")))
    # Uncomment next line if you want real interactive "Press Enter"
    # input()

def cmd_version(args):
    """Hiển thị version"""
    from ikigai import __version__
    print(f"ikigai v{__version__}")

def cmd_hello(args):
    """Lệnh chào hỏi cơ bản"""
    from ikigai import __version__
    name = args.name or "World"
    console.print(Panel(f"[bold green]👋 Hello, {name}![/] Welcome to [bold #afca31]IKIGAI AI[/] CLI v{__version__}", border_style="green"))

def cmd_info(args):
    """Hiển thị thông tin hệ thống"""
    from ikigai import __version__
    info = {
        "Tool": "IKIGAI AI CLI",
        "Version": __version__,
        "Python": sys.version.split()[0],
        "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "Team": "IKIGAI Platform Team",
    }
    
    if args.json:
        console.print(json.dumps(info, indent=2))
    else:
        table = Table(title="[bold #afca31]System Information[/]", border_style="#afca31")
        table.add_column("Property", style="bold cyan")
        table.add_column("Value", style="white")
        
        for key, value in info.items():
            table.add_row(key, value)
        
        console.print(table)

def cmd_process(args):
    """Xử lý dữ liệu demo"""
    with console.status("[bold green]⚙️  Processing data...", spinner="dots"):
        import time
        time.sleep(2)  # Giả lập xử lý
        console.print(f"[bold cyan]📁 File:[/] {args.input}")
        console.print(f"[bold cyan]📂 Output:[/] {args.output}")
        console.print("[bold green]✅ Success![/]")

def cmd_ask(args):
    """Hỏi đáp với AI qua Gemini"""
    import os
    import json
    
    # 1. Tự động đọc API KEY từ file .env (nếu có)
    try:
        from dotenv import load_dotenv
        load_dotenv()
    except ImportError:
        pass

    # 2. Khởi tạo thư viện mới của Google (google-genai)
    try:
        from google import genai
    except ImportError:
        console.print("[bold red]Lỗi:[/] Thư viện google-genai chưa được cài đặt. Hãy chạy 'pip install -e .'")
        sys.exit(1)
        
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        console.print("[bold red]Lỗi:[/] Thiếu cấu hình GEMINI_API_KEY.")
        console.print("Hãy đảm bảo bạn đã điền key vào file .env")
        sys.exit(1)
        
    try:
        client = genai.Client(api_key=api_key)
        
        if not args.quiet and not args.json:
            with console.status("[bold cyan]🤖 Đang suy nghĩ...[/]", spinner="dots"):
                response = client.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=args.question,
                )
        else:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=args.question,
            )
            
        if args.json:
            print(json.dumps({"question": args.question, "answer": response.text}, ensure_ascii=False, indent=2))
        elif args.quiet:
            print(response.text)
        else:
            console.print(Panel(response.text, title="🤖 [bold #afca31]Gemini AI Answer[/]", border_style="blue"))
            
    except Exception as e:
        console.print(f"[bold red]Lỗi API:[/] {str(e)}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        prog="ikigai",
        description="🛠  IKIGAI AI - Internal CLI SDK by Platform Team",
        add_help=False
    )
    # Customize help to show splash
    parser.add_argument('-h', '--help', action='store_true', help='show this help message and exit')
    
    subparsers = parser.add_subparsers(dest="command")

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

    # Command: ask
    p_ask = subparsers.add_parser("ask", help="Hỏi đáp với trợ lý AI Gemini")
    p_ask.add_argument("question", help="Câu hỏi của bạn")
    p_ask.add_argument("--quiet", action="store_true", help="Chỉ in ra câu trả lời thô")
    p_ask.add_argument("--json", action="store_true", help="Đầu ra định dạng JSON")

    args, unknown = parser.parse_known_args()

    if args.help or not args.command:
        show_splash()
        parser.print_help()
        sys.exit(0)

    if args.command == "hello":
        cmd_hello(args)
    elif args.command == "info":
        cmd_info(args)
    elif args.command == "process":
        cmd_process(args)
    elif args.command == "ask":
        cmd_ask(args)

if __name__ == "__main__":
    main()
