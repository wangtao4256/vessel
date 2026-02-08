from fastapi import APIRouter
from app.api.v1.endpoints import example, workspace

api_router = APIRouter()

api_router.include_router(example.router, prefix="/examples", tags=["示例管理"])
api_router.include_router(workspace.router, prefix="/workspace", tags=["工作空间"])
