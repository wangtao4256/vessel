from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.database import Base


class OpenCodeEvent(Base):
    """OpenCode SSE 事件存储模型"""

    __tablename__ = "opencode_events"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    event_type = Column(String(100), nullable=True, comment="事件类型")
    event_data = Column(Text, nullable=False, comment="事件数据 (JSON)")
    event_id = Column(String(100), nullable=True, comment="SSE event id")
    session_id = Column(String(100), nullable=True, index=True, comment="会话ID")
    created_at = Column(DateTime, server_default=func.now(), comment="接收时间")

    def __repr__(self):
        return f"<OpenCodeEvent(id={self.id}, type={self.event_type})>"
