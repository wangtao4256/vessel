from fastapi import APIRouter
from app.schemas.build import BuildImageRequest, BuildImageResponse
from app.services.build_service import (
    build_and_push_image,
    ACR_REGISTRY,
    ACR_NAMESPACE,
    IMAGE_NAME,
)

router = APIRouter()


@router.post("/image", response_model=BuildImageResponse)
async def build_image(request: BuildImageRequest):
    success, logs, image_tag = await build_and_push_image(
        project_name=request.project_name,
        dockerfile=request.dockerfile,
        push=request.push,
    )

    full_url = f"{ACR_REGISTRY}/{ACR_NAMESPACE}/{IMAGE_NAME}:{request.project_name}"

    return BuildImageResponse(
        success=success,
        message="构建成功" if success else "构建失败",
        image_tag=request.project_name,
        full_image_url=full_url if success else None,
        build_log=logs,
    )
