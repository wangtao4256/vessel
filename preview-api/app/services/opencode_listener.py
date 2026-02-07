import asyncio
import httpx
from typing import Optional
from app.database import AsyncSessionLocal
from app.models.opencode_event import OpenCodeEvent


class OpenCodeEventListener:
    def __init__(self, opencode_url: str = "http://localhost:4096"):
        self.opencode_url = opencode_url
        self.running = False
        self._task: Optional[asyncio.Task] = None

    async def start(self):
        if self.running:
            return
        self.running = True
        self._task = asyncio.create_task(self._listen())
        print(f"✅ OpenCode 事件监听已启动: {self.opencode_url}/event")

    async def stop(self):
        self.running = False
        if self._task:
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass
        print("🛑 OpenCode 事件监听已停止")

    async def _listen(self):
        while self.running:
            try:
                await self._connect_and_listen()
            except Exception as e:
                print(f"⚠️ 监听连接断开: {e}, 5秒后重连...")
                await asyncio.sleep(5)

    async def _connect_and_listen(self):
        # SSE 长连接需要禁用读取超时，否则空闲时会断开
        timeout = httpx.Timeout(connect=30.0, read=None, write=None, pool=None)
        async with httpx.AsyncClient(timeout=timeout) as client:
            async with client.stream("GET", f"{self.opencode_url}/event") as resp:
                await self._process_stream(resp)

    async def _process_stream(self, resp):
        event_type = None
        event_data = None
        event_id = None

        async for line in resp.aiter_lines():
            if not line:
                if event_data:
                    await self._save_event(event_type, event_data, event_id)
                event_type = event_data = event_id = None
                continue

            if line.startswith("event:"):
                event_type = line[6:].strip()
            elif line.startswith("data:"):
                event_data = line[5:].strip()
            elif line.startswith("id:"):
                event_id = line[3:].strip()

    async def _save_event(
        self, event_type: Optional[str], event_data: str, event_id: Optional[str]
    ):
        async with AsyncSessionLocal() as session:
            event = OpenCodeEvent(
                event_type=event_type, event_data=event_data, event_id=event_id
            )
            session.add(event)
            await session.commit()


listener = OpenCodeEventListener()
