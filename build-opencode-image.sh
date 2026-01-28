#!/bin/bash

set -e

# ==================== 配置区域 ====================
# 阿里云镜像仓库配置（请修改为你的实际地址）
ALIYUN_REGISTRY="ziwuxian-registry.cn-beijing.cr.aliyuncs.com"  # 阿里云地域
ALIYUN_NAMESPACE="ai-coding"                     # 你的命名空间
IMAGE_NAME="vessel"                      # 镜像名称

# 版本策略：semver | timestamp | auto
VERSION_MODE=${1:-"semver"}
VERSION_ARG=${2:-"1.0.0"}

# ==================== 版本生成逻辑 ====================
case $VERSION_MODE in
  semver)
    # 语义化版本（手动指定）
    if [ -z "$VERSION_ARG" ]; then
      echo "Error: semver mode requires version argument"
      echo "Usage: $0 semver 1.0.0"
      exit 1
    fi
    IMAGE_TAG="v${VERSION_ARG}"
    ;;
  timestamp)
    # 时间戳 + Git SHA（推荐用于开发/测试）
    GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    IMAGE_TAG="${TIMESTAMP}-${GIT_SHA}"
    ;;
  auto)
    # 自动检测：有 git tag 用 semver，否则用 timestamp
    GIT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "")
    if [ -n "$GIT_TAG" ]; then
      IMAGE_TAG="${GIT_TAG}"
    else
      GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
      TIMESTAMP=$(date +%Y%m%d)
      IMAGE_TAG="${TIMESTAMP}-${GIT_SHA}"
    fi
    ;;
  *)
    echo "Unknown version mode: $VERSION_MODE"
    echo "Usage: $0 [semver|timestamp|auto] [version]"
    echo ""
    echo "Examples:"
    echo "  $0 semver 1.0.0        # 生成 v1.0.0"
    echo "  $0 timestamp           # 生成 20240128-110642-abc1234"
    echo "  $0 auto                # 自动检测"
    exit 1
    ;;
esac

# 完整镜像地址
FULL_IMAGE_NAME="${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}"
EXPORT_FILE="${IMAGE_NAME}_${IMAGE_TAG}.tar.gz"

echo "=========================================="
echo "Building OpenCode Vessel Environment"
echo "=========================================="
echo "Version Mode: ${VERSION_MODE}"
echo "Image Tag:    ${IMAGE_TAG}"
echo "Full Image:   ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
echo "=========================================="
echo ""

# ==================== 构建镜像 ====================
echo "Step 1: Building Docker image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# 打标签
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}:${IMAGE_TAG}

echo "✓ Build complete!"
echo ""

# ==================== 导出镜像（可选） ====================
read -p "Export image to ${EXPORT_FILE}? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Step 2: Exporting image..."
  docker save ${FULL_IMAGE_NAME}:${IMAGE_TAG} | gzip > ${EXPORT_FILE}
  echo "✓ Export complete: ${EXPORT_FILE}"
  echo ""
fi

# ==================== 推送到阿里云 ====================
read -p "Push to Aliyun registry? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Step 3: Pushing to Aliyun..."
  echo "Logging in to ${ALIYUN_REGISTRY}..."
  echo "Please enter your Aliyun credentials:"
  docker login ${ALIYUN_REGISTRY}
  
  echo ""
  echo "Pushing ${FULL_IMAGE_NAME}:${IMAGE_TAG}..."
  docker push ${FULL_IMAGE_NAME}:${IMAGE_TAG}
  
  echo ""
  echo "✓ Push complete!"
  echo ""
  echo "=========================================="
  echo "Image pushed successfully!"
  echo "=========================================="
  echo "Pull command:"
  echo "  docker pull ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
  echo ""
fi

# ==================== 使用说明 ====================
echo "=========================================="
echo "Local Usage:"
echo "=========================================="
echo "Run container:"
echo "  docker run -d --name opencode-vessel \\"
echo "    -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \\"
echo "    ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "Access services:"
echo "  - OpenCode Web: http://localhost:4096"
echo "  - Vessel Backend: http://localhost:3300"
echo "  - Vessel Frontend: http://localhost:5173"
echo ""
echo "Useful commands:"
echo "  docker logs opencode-vessel          # View logs"
echo "  docker logs -f opencode-vessel       # Follow logs"
echo "  docker stop opencode-vessel          # Stop container"
echo "  docker start opencode-vessel         # Start container"
echo "  docker rm -f opencode-vessel         # Remove container"
echo "=========================================="
