from fastapi import APIRouter
from app.api.v1.endpoints import example, workspace, server, auth

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["认证"])
api_router.include_router(example.router, prefix="/examples", tags=["示例管理"])
api_router.include_router(workspace.router, prefix="/workspace", tags=["工作空间"])
api_router.include_router(server.router, prefix="/server", tags=["服务器管理"])
