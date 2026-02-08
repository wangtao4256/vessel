from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config import get_settings
from app.database import init_db
from app.api.v1 import api_router
from app.services.opencode_listener import listener

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    print("✅ 数据库初始化完成")
    await listener.start()
    yield
    await listener.stop()
    print("👋 应用关闭")


# 创建 FastAPI 应用
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="FastAPI + SQLite 脚手架",
    lifespan=lifespan,
)

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(api_router, prefix="/api/v1")


@app.get("/")
async def root():
    """根路径"""
    return {
        "message": "Welcome to FastAPI + SQLite Scaffold",
        "version": settings.app_version,
        "docs": "/docs",
    }


@app.get("/health")
async def health_check():
    """健康检查"""
    import os

    workspace_path = os.getcwd()
    workspace_name = os.path.basename(workspace_path)
    return {"status": "healthy", "workspace": workspace_name, "path": workspace_path}
