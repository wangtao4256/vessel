"""镜像构建相关的 Schema"""

from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


class BuildStatus(str, Enum):
    """构建状态"""

    PENDING = "pending"
    BUILDING = "building"
    PUSHING = "pushing"
    SUCCESS = "success"
    FAILED = "failed"


class BuildImageRequest(BaseModel):
    """构建镜像请求"""

    project_name: str = Field(
        ...,
        description="项目名称，用作镜像 tag，同时作为 /workspace/{project_name} 的构建上下文",
    )
    dockerfile: str = Field(
        default="Dockerfile.preview", description="Dockerfile 文件名"
    )
    push: bool = Field(default=True, description="是否推送到 ACR")


class BuildImageResponse(BaseModel):
    """构建镜像响应"""

    success: bool
    message: str
    image_tag: Optional[str] = None
    full_image_url: Optional[str] = None
    build_log: Optional[str] = None
