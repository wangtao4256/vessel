from fastapi import APIRouter
from app.api.v1.endpoints import example

api_router = APIRouter()

# 注册子路由
api_router.include_router(example.router, prefix="/examples", tags=["示例管理"])
