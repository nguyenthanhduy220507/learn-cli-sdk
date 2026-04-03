import sys
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.table import Table
from rich.align import Align
from rich.theme import Theme

# Custom theme for Ikigai
custom_theme = Theme({
    "info": "dim cyan",
    "warning": "magenta",
    "danger": "bold red",
    "success": "bold green",
    "highlight": "#afca31",
})

console = Console(theme=custom_theme)

IKIGAI_ASCII = """
 ██╗██╗  ██╗██╗ ██████╗  █████╗ ██╗     █████╗ ██╗
 ██║██║ ██╔╝██║██╔════╝ ██╔══██╗██║    ██╔══██╗██║
 ██║█████╔╝ ██║██║  ███╗███████║██║    ███████║██║
 ██║██╔═██╗ ██║██║   ██║██╔══██║██║    ██╔══██║██║
 ██║██║  ██╗██║╚██████╔╝██║  ██║██║    ██║  ██║██║
 ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝    ╚═╝  ╚═╝╚═╝
"""

def show_splash():
    """Display the IKIGAI AI splash screen."""
    header_text = Text("Welcome to IKIGAI AI", style="bold white on #afca31")
    console.print(Align.center(Panel(header_text, border_style="#afca31", padding=(0, 2))))
    
    logo = Text(IKIGAI_ASCII, style="#afca31")
    console.print(Align.center(logo))
    console.print()

def print_error(message: str):
    console.print(f"[bold red]Error:[/] {message}")

def print_success(message: str):
    console.print(f"[bold green]Success:[/] {message}")

def format_table(title: str, columns: list[str], rows: list[list[str]]):
    table = Table(title=f"[bold highlight]{title}[/]", border_style="highlight")
    for col in columns:
        table.add_column(col)
    for row in rows:
        table.add_row(*row)
    return table
