#!/bin/bash

set -e

IMAGE_NAME="opencode-vessel-env"
IMAGE_TAG="latest"
EXPORT_FILE="${IMAGE_NAME}_latest.tar.gz"

echo "Building OpenCode environment image..."

docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "Build complete! Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Exporting image to ${EXPORT_FILE}..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} | gzip > ${EXPORT_FILE}
echo "Export complete! File: ${EXPORT_FILE}"
echo ""
echo "To run the container:"
echo "  docker run -d --name opencode-vessel -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Access OpenCode web at: http://localhost:4096"
echo ""
echo "Useful commands:"
echo "  docker logs opencode-vessel          # View logs"
echo "  docker logs -f opencode-vessel       # Follow logs"
echo "  docker stop opencode-vessel          # Stop container"
echo "  docker start opencode-vessel         # Start container"
echo "  docker rm -f opencode-vessel         # Remove container"
