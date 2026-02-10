import shutil
import subprocess
import re
from pathlib import Path
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

SOURCE_DIR = "./workspace"
WORKSPACE_ROOT = "/workspace"
CURRENT_PROJECT_DIR_FILE = "/workspace/.current_project_dir"


class CopyRequest(BaseModel):
    targetPath: str


class CopyResponse(BaseModel):
    success: bool
    message: str
    source: str
    target: str

FRONTEND_PORT_FILE = "/var/log/vessel/frontend.port"



@router.post("/copy", response_model=CopyResponse)
async def copy_workspace(request: CopyRequest):
    source = Path(SOURCE_DIR)
    project_name = request.targetPath.lstrip("/")
    target = Path(WORKSPACE_ROOT) / project_name

    if not source.exists():
        raise HTTPException(status_code=404, detail=f"源目录不存在: {SOURCE_DIR}")

    try:
        if target.exists():
            shutil.rmtree(target)

        shutil.copytree(source, target)

        Path(CURRENT_PROJECT_DIR_FILE).write_text(project_name)

        return CopyResponse(
            success=True, message="复制成功", source=str(source), target=str(target)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"复制失败: {str(e)}")
