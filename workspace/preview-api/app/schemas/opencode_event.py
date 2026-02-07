from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class OpenCodeEventResponse(BaseModel):
    id: int
    event_type: Optional[str]
    event_data: str
    event_id: Optional[str]
    session_id: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
