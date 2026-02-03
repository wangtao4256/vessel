import asyncio
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from sqlalchemy import select
from app.database import AsyncSessionLocal
from app.models.opencode_event import OpenCodeEvent

router = APIRouter()


async def event_generator():
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(OpenCodeEvent).order_by(OpenCodeEvent.id))
        events = result.scalars().all()

        for event in events:
            if event.event_type:
                yield f"event: {event.event_type}\n"
            if event.event_id:
                yield f"id: {event.event_id}\n"
            yield f"data: {event.event_data}\n\n"
            await asyncio.sleep(0.01)


@router.get("/replay")
async def replay_events():
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
