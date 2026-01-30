from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.database import Base


class ExampleModel(Base):
    """示例数据模型"""

    __tablename__ = "examples"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title = Column(String(200), nullable=False, comment="标题")
    content = Column(Text, nullable=True, comment="内容")
    status = Column(Integer, default=1, comment="状态: 0-禁用, 1-启用")
    created_at = Column(DateTime, server_default=func.now(), comment="创建时间")
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment="更新时间")

    def __repr__(self):
        return f"<ExampleModel(id={self.id}, title={self.title})>"
