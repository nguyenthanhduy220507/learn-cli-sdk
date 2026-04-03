import os
import json
import httpx
from pathlib import Path
from typing import Optional, AsyncGenerator

CONFIG_DIR = Path.home() / ".ikigai"
CONFIG_FILE = CONFIG_DIR / "config.json"

class IkigaiClient:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url.rstrip("/")
        self.token: Optional[str] = None
        self._load_config()

    def _load_config(self):
        if CONFIG_FILE.exists():
            try:
                data = json.loads(CONFIG_FILE.read_text())
                self.token = data.get("token")
            except Exception:
                pass

    def _save_config(self):
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        CONFIG_FILE.write_text(json.dumps({"token": self.token}))

    @property
    def headers(self):
        h = {"Content-Type": "application/json"}
        if self.token:
            h["Authorization"] = f"Bearer {self.token}"
        return h

    async def login(self, email: str, password: str):
        url = f"{self.base_url}/api/v1/auth/login"
        async with httpx.AsyncClient() as client:
            resp = await client.post(url, json={"email": email, "password": password})
            if resp.status_code == 200:
                data = resp.json()
                self.token = data["token"]
                self._save_config()
                return data
            else:
                raise Exception(f"Login failed: {resp.text}")

    async def get_status(self):
        url = f"{self.base_url}/health" # or /api/v1/status
        async with httpx.AsyncClient() as client:
            resp = await client.get(url)
            return resp.json()

    async def list_documents(self):
        url = f"{self.base_url}/api/v1/documents/mine"
        async with httpx.AsyncClient() as client:
            resp = await client.get(url, headers=self.headers)
            resp.raise_for_status()
            return resp.json()["data"]

    async def upload_document(self, file_path: str):
        url = f"{self.base_url}/api/v1/documents/upload"
        path = Path(file_path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {file_path}")

        async with httpx.AsyncClient() as client:
            with open(path, "rb") as f:
                files = {"file": (path.name, f)}
                resp = await client.post(url, headers={"Authorization": f"Bearer {self.token}"}, files=files)
                resp.raise_for_status()
                return resp.json()["data"]

    async def chat_stream(
        self, 
        question: str, 
        conversation_id: Optional[str] = None,
        history: Optional[list] = None
    ) -> AsyncGenerator[dict, None]:
        url = f"{self.base_url}/api/v1/chat/stream"
        payload = {
            "query": question,
            "stream": True,
            "conversation_id": conversation_id,
            "conversation_history": history or []
        }
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            async with client.stream("POST", url, headers=self.headers, json=payload) as response:
                response.raise_for_status()
                async for line in response.aiter_lines():
                    if line.startswith("data: "):
                        content = line[6:].strip()
                        if content == "[DONE]":
                            break
                        try:
                            data = json.loads(content)
                            # Yield the whole data dict so caller can handle different event types
                            yield data
                        except json.JSONDecodeError:
                            continue
