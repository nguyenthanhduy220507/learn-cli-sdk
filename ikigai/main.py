import asyncio
import json
import typer
from typing import Optional
from ikigai import __version__
from ikigai.client import IkigaiClient
from ikigai.ui import console, show_splash, print_error, print_success, format_table
from rich.live import Live
from rich.panel import Panel
from rich.text import Text
from rich.markdown import Markdown

app = typer.Typer(help="🛠  IKIGAI AI - Internal CLI SDK by Platform Team")
config_app = typer.Typer(help="Configure IKIGAI CLI settings.")
client = IkigaiClient()

app.add_typer(config_app, name="config")

def version_callback(value: bool):
    if value:
        console.print(f"IKIGAI CLI Version: [bold]{__version__}[/]")
        raise typer.Exit()

@app.callback()
def main(
    version: Optional[bool] = typer.Option(
        None, "--version", "-v", help="Show version and exit.", callback=version_callback, is_eager=True
    ),
):
    """
    IKIGAI AI Platform CLI - Modern modular interface.
    """
    pass

@app.command()
def login(
    email: str = typer.Option(..., prompt=True),
    password: str = typer.Option(..., prompt=True, hide_input=True),
):
    """Authenticate with the IKIGAI AI Platform."""
    try:
        with console.status("[bold green]Authenticating..."):
            asyncio.run(client.login(email, password))
        print_success(f"Successfully logged in as [bold]{email}[/]")
    except Exception as e:
        print_error(str(e))

@app.command()
def hello(name: str = typer.Option("World", "--name", help="Name to greet.")):
    """Say hello (legacy compatibility command)."""
    console.print(f"Hello, {name}!")

@config_app.command("server")
def config_server(base_url: str):
    """Set backend server URL used by CLI commands."""
    try:
        saved_url = client.set_server(base_url)
        print_success(f"Server URL configured: [bold]{saved_url}[/]")
    except ValueError as e:
        print_error(str(e))
        raise typer.Exit(code=2)

@app.command()
def info(json_output: bool = typer.Option(False, "--json", help="Output status in JSON format.")):
    """Display system and connection information."""
    try:
        status = asyncio.run(client.get_status())
        main_status = status.get("status", "unknown")
        is_online = main_status in ["healthy", "ok"]

        if json_output:
            payload = {
                "status": "online" if is_online else "offline",
                "raw_status": main_status,
                "version": "1.0.0",
                "environment": status.get("environment", "unknown"),
                "endpoint": client.base_url,
                "services": status.get("services", {}),
            }
            console.print(json.dumps(payload, ensure_ascii=False))
            return

        show_splash()
        
        rows = [
            ["Status", "[green]Online" if is_online else f"[red]Offline ({main_status})"],
            ["Version", "1.0.0"], # Hardcoded for now as backend /health logic doesn't return app version yet
            ["Environment", status.get("environment", "unknown")],
            ["Endpoint", client.base_url],
        ]
        table = format_table("Platform Info", ["Property", "Value"], rows)
        console.print(table)
        
        if "services" in status:
            svc_rows = [
                [svc, "[green]ok" if val == "ok" else f"[red]{val}"]
                for svc, val in status["services"].items()
            ]
            svc_table = format_table("Service Health", ["Service", "Status"], svc_rows)
            console.print(svc_table)
            
    except Exception as e:
        if json_output:
            console.print(json.dumps({"error": str(e), "endpoint": client.base_url}, ensure_ascii=False))
            return
        print_error(f"Could not connect to the IKIGAI platform: {e}")

@app.command()
def docs():
    """List your uploaded documents."""
    try:
        documents = asyncio.run(client.list_documents())
        if not documents:
            console.print("[yellow]No documents found.[/]")
            return

        rows = [
            [d["id"][:8], d["filename"], d["doc_type"], d["status"], d["created_at"]]
            for d in documents
        ]
        table = format_table("My Documents", ["ID", "Filename", "Type", "Status", "Created"], rows)
        console.print(table)
    except Exception as e:
        print_error(f"Failed to fetch documents: {e}")

@app.command()
def upload(file_path: str):
    """Upload a document to the IKIGAI AI Platform."""
    try:
        with console.status(f"[bold cyan]Uploading {file_path}..."):
            doc = asyncio.run(client.upload_document(file_path))
        print_success(f"Document uploaded: [bold]{doc['filename']}[/] (ID: {doc['id']})")
    except Exception as e:
        print_error(f"Upload failed: {e}")

@app.command()
def ask(question: str):
    """Ask a single question to the IKIGAI AI Assistant."""
    async def run_chat():
        full_response = ""
        with Live(Panel(Text("🤖 Thinking..."), title="[bold highlight]Ikigai AI[/]", border_style="highlight"), refresh_per_second=10, console=console) as live:
            try:
                async for event in client.chat_stream(question):
                    if event.get("type") == "token":
                        full_response += event.get("content", "")
                        live.update(Panel(Markdown(full_response), title="[bold highlight]Ikigai AI[/]", border_style="highlight"))
            except Exception as e:
                print_error(f"Chat failed: {e}")

    asyncio.run(run_chat())

@app.command()
def chat():
    """Start an interactive chat session with the IKIGAI AI Assistant."""
    show_splash()
    console.print("[info]Type '/exit' or '/quit' to end the session.[/]")
    console.print("[info]Type '/clear' to reset the conversation history.[/]\n")
    
    conversation_id = None
    history = []
    
    while True:
        try:
            query = console.input("[bold highlight]You:[/] ").strip()
            
            if not query:
                continue
                
            if query.lower() in ["/exit", "/quit"]:
                print_success("Goodbye!")
                break
                
            if query.lower() == "/clear":
                conversation_id = None
                history = []
                print_success("Conversation history cleared.")
                continue

            async def run_interaction(q: str, cid: Optional[str], h: list):
                nonlocal conversation_id
                full_response = ""
                with Live(Panel(Text("🤖 Thinking..."), title="[bold highlight]Ikigai AI[/]", border_style="highlight"), refresh_per_second=10, console=console) as live:
                    async for event in client.chat_stream(q, conversation_id=cid, history=h):
                        etype = event.get("type")
                        if etype == "token":
                            full_response += event.get("content", "")
                            live.update(Panel(Markdown(full_response), title="[bold highlight]Ikigai AI[/]", border_style="highlight"))
                        elif etype == "done":
                            conversation_id = event.get("conversation_id") or conversation_id
                
                # Update history for next turn
                h.append({"role": "user", "content": q})
                h.append({"role": "assistant", "content": full_response})
                # Keep history manageable
                if len(h) > 20:
                    h[:] = h[-20:]

            asyncio.run(run_interaction(query, conversation_id, history))
            console.print() # Spacer

        except KeyboardInterrupt:
            print_success("\nGoodbye!")
            break
        except Exception as e:
            print_error(f"Interaction failed: {e}")

def start():
    app()

if __name__ == "__main__":
    start()
