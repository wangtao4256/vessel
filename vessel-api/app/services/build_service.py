import asyncio
from typing import Tuple
from app.config import get_settings

settings = get_settings()

ACR_REGISTRY = settings.acr_registry
ACR_NAMESPACE = settings.acr_namespace
IMAGE_NAME = settings.acr_image_name


async def run_command(cmd: str) -> Tuple[int, str, str]:
    proc = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )
    stdout, stderr = await proc.communicate()
    return proc.returncode, stdout.decode(), stderr.decode()


WORKSPACE_PATH = "/workspace"
DOCKERFILE_PATH = "/vessel-api/docker"


async def build_and_push_image(
    project_name: str,
    dockerfile: str = "Dockerfile.preview",
    push: bool = True,
) -> Tuple[bool, str, str]:
    image_tag = f"{ACR_REGISTRY}/{ACR_NAMESPACE}/{IMAGE_NAME}:{project_name}"
    logs = []

    dockerfile_path = f"{DOCKERFILE_PATH}/{dockerfile}"
    build_context = f"{WORKSPACE_PATH}/{project_name}"

    build_cmd = f"docker build -t {image_tag} -f {dockerfile_path} {build_context}"
    logs.append(f"[BUILD] {build_cmd}")

    code, stdout, stderr = await run_command(build_cmd)
    logs.append(stdout)
    if stderr:
        logs.append(f"[STDERR] {stderr}")

    if code != 0:
        return False, "\n".join(logs), image_tag

    if push:
        acr_password = settings.get_acr_password()
        if not settings.acr_username or not acr_password:
            logs.append("[ERROR] ACR_USERNAME or ACR_PASSWORD_ENCRYPTED not set")
            return False, "\n".join(logs), image_tag

        login_cmd = (
            f"docker login {ACR_REGISTRY} -u {settings.acr_username} -p {acr_password}"
        )
        logs.append(f"[LOGIN] docker login {ACR_REGISTRY}")

        code, stdout, stderr = await run_command(login_cmd)
        if code != 0:
            logs.append(f"[STDERR] {stderr}")
            return False, "\n".join(logs), image_tag

        push_cmd = f"docker push {image_tag}"
        logs.append(f"[PUSH] {push_cmd}")

        code, stdout, stderr = await run_command(push_cmd)
        logs.append(stdout)
        if stderr:
            logs.append(f"[STDERR] {stderr}")

        if code != 0:
            return False, "\n".join(logs), image_tag

    return True, "\n".join(logs), image_tag
