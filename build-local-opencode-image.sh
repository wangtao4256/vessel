#!/bin/bash

set -e

IMAGE_NAME="opencode-vessel-env"
IMAGE_TAG="latest"
EXPORT_FILE="${IMAGE_NAME}_latest.tar.gz"

# 清理旧的导出文件
if [ -f "${EXPORT_FILE}" ]; then
    echo "Removing old export file: ${EXPORT_FILE}"
    rm -f "${EXPORT_FILE}"
fi

# 停止并删除已存在的容器
if docker ps -a --format '{{.Names}}' | grep -q "^opencode-vessel$"; then
    echo "Stopping and removing existing container: opencode-vessel"
    docker rm -f opencode-vessel
fi

# 删除旧镜像
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}:${IMAGE_TAG}$"; then
    echo "Removing old image: ${IMAGE_NAME}:${IMAGE_TAG}"
    docker rmi ${IMAGE_NAME}:${IMAGE_TAG}
fi

echo ""
echo "Building OpenCode environment image..."

docker build -f Dockerfile -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "Build complete! Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Exporting image to ${EXPORT_FILE}..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} | gzip > ${EXPORT_FILE}
echo "Export complete! File: ${EXPORT_FILE}"
echo ""
echo "Starting container..."
docker run -d \
  --name opencode-vessel \
  -p 3000:3000 \
  -p 3300:3300 \
  -p 4096:4096 \
  -p 5173-5193:5173-5193 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ${IMAGE_NAME}:${IMAGE_TAG}
echo "Container started!"
echo ""
echo "To run the container manually:"
echo "  docker run -d --name opencode-vessel -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173-5193:5173-5193 ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Access OpenCode web at: http://localhost:4096"
echo ""
echo "Useful commands:"
echo "  docker logs opencode-vessel          # View logs"
echo "  docker logs -f opencode-vessel       # Follow logs"
echo "  docker stop opencode-vessel          # Stop container"
echo "  docker start opencode-vessel         # Start container"
echo "  docker rm -f opencode-vessel         # Remove container"
