#!/usr/bin/env python3
"""
mycli - IKIGAI AI CLI SDK
"""

import argparse
import json
import sys
from datetime import datetime
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
    header_text = Text("Welcome to IKIGAI AI", style="bold white on #d75f5f")
    console.print(Align.center(Panel(header_text, border_style="#d75f5f", padding=(0, 2))))
    
    # Large Logo
    logo = Text(IKIGAI_ASCII, style="#d75f5f")
    console.print(Align.center(logo))
    
    console.print(Align.center(Text("Press Enter to continue...", style="dim italic blue")))
    # Uncomment next line if you want real interactive "Press Enter"
    # input()

def cmd_version(args):
    """Hiển thị version"""
    from mycli import __version__
    print(f"mycli v{__version__}")

def cmd_hello(args):
    """Lệnh chào hỏi cơ bản"""
    from mycli import __version__
    name = args.name or "World"
    console.print(Panel(f"[bold green]👋 Hello, {name}![/] Welcome to [bold #d75f5f]IKIGAI AI[/] CLI v{__version__}", border_style="green"))

def cmd_info(args):
    """Hiển thị thông tin hệ thống"""
    from mycli import __version__
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
        table = Table(title="[bold #d75f5f]System Information[/]", border_style="#d75f5f")
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
    try:
        import google.generativeai as genai
    except ImportError:
        console.print("[bold red]Lỗi:[/] Thư viện google-generativeai chưa được cài đặt.")
        sys.exit(1)
        
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        console.print("[bold red]Lỗi:[/] Thiếu cấu hình GEMINI_API_KEY.")
        console.print("Vui lòng cấu hình API Key thông qua biến môi trường.")
        console.print("Ví dụ: [cyan]export GEMINI_API_KEY='your_api_key'[/] hoặc truyền [cyan]-e GEMINI_API_KEY=...[/] nếu dùng Docker.")
        sys.exit(1)
        
    try:
        if not args.quiet and not args.json:
            with console.status("[bold cyan]🤖 Đang suy nghĩ...[/]", spinner="dots"):
                genai.configure(api_key=api_key)
                model = genai.GenerativeModel('gemini-1.5-flash')
                response = model.generate_content(args.question)
        else:
            genai.configure(api_key=api_key)
            model = genai.GenerativeModel('gemini-1.5-flash')
            response = model.generate_content(args.question)
            
        if args.json:
            print(json.dumps({"question": args.question, "answer": response.text}, ensure_ascii=False, indent=2))
        elif args.quiet:
            print(response.text)
        else:
            console.print(Panel(response.text, title="🤖 [bold #d75f5f]Gemini AI Answer[/]", border_style="blue"))
            
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
