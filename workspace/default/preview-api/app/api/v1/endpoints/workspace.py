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


class StartScriptRequest(BaseModel):
    """启动脚本请求"""

    project_name: str


class StartScriptResponse(BaseModel):
    """启动脚本响应"""

    success: bool
    message: str
    port: Optional[int] = None
    project_name: str


FRONTEND_PORT_FILE = "/var/log/vessel/frontend.port"


@router.post("/start", response_model=StartScriptResponse)
async def start_workspace_script(request: StartScriptRequest):
    project_name = request.project_name.strip().lstrip("/")

    if not project_name or ".." in project_name or project_name.startswith("/"):
        raise HTTPException(status_code=400, detail="无效的项目名称")

    project_path = Path(WORKSPACE_ROOT) / project_name
    script_path = project_path / "scripts" / "start-vessel.sh"

    if not project_path.exists():
        raise HTTPException(status_code=404, detail=f"项目不存在: {project_name}")

    if not script_path.exists():
        raise HTTPException(status_code=404, detail=f"启动脚本不存在: {script_path}")

    try:
        resolved_path = script_path.resolve()
        if not str(resolved_path).startswith(WORKSPACE_ROOT):
            raise HTTPException(status_code=403, detail="禁止访问 workspace 外的路径")
    except Exception:
        raise HTTPException(status_code=400, detail="路径解析失败")

    try:
        result = subprocess.run(
            ["bash", str(script_path)],
            capture_output=True,
            text=True,
            timeout=60,
            cwd=str(project_path),
        )

        port = None
        port_file = Path(FRONTEND_PORT_FILE)
        if port_file.exists():
            try:
                port = int(port_file.read_text().strip())
            except ValueError:
                pass

        if port is None:
            port_match = re.search(r"使用端口:\s*(\d+)", result.stdout)
            if port_match:
                port = int(port_match.group(1))

        success = result.returncode == 0
        message = (
            "启动成功" if success else f"启动失败: {result.stderr or result.stdout}"
        )

        return StartScriptResponse(
            success=success, message=message, port=port, project_name=project_name
        )

    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=504, detail="脚本执行超时")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"执行失败: {str(e)}")


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
