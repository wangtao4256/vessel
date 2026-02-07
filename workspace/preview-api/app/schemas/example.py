from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


class ExampleBase(BaseModel):
    """示例基础模型"""

    title: str = Field(..., min_length=1, max_length=200, description="标题")
    content: Optional[str] = Field(None, description="内容")
    status: int = Field(1, ge=0, le=1, description="状态: 0-禁用, 1-启用")


class ExampleCreate(ExampleBase):
    """创建示例请求"""

    pass


class ExampleUpdate(BaseModel):
    """更新示例请求"""

    title: Optional[str] = Field(None, min_length=1, max_length=200, description="标题")
    content: Optional[str] = Field(None, description="内容")
    status: Optional[int] = Field(None, ge=0, le=1, description="状态")


class ExampleResponse(ExampleBase):
    """示例响应"""

    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
