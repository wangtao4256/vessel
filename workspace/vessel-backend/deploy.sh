#!/bin/bash

# FastAPI 项目一键部署脚本
# 适用于 Linux/macOS 服务器

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 打印欢迎信息
echo "=========================================="
echo "  vessel-backend 项目一键部署脚本"
echo "=========================================="
echo ""

# 1. 检查 Python 版本
log_info "检查 Python 环境..."

if ! command_exists python3; then
    log_error "未找到 Python3，请先安装 Python 3.11 或更高版本"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}')
log_info "当前 Python 版本: $PYTHON_VERSION"

# 检查 Python 版本是否 >= 3.11
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 11 ]); then
    log_error "Python 版本过低，需要 Python 3.11 或更高版本"
    exit 1
fi

# 2. 创建虚拟环境
log_info "创建虚拟环境..."

if [ -d "venv" ]; then
    log_warn "虚拟环境已存在，是否删除并重新创建? (y/n)"
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        rm -rf venv
        log_info "已删除旧的虚拟环境"
    else
        log_info "使用现有虚拟环境"
    fi
fi

if [ ! -d "venv" ]; then
    python3 -m venv venv
    log_info "虚拟环境创建成功"
fi

# 3. 激活虚拟环境
log_info "激活虚拟环境..."
source venv/bin/activate

# 4. 升级 pip
log_info "升级 pip..."
pip install --upgrade pip -q

# 5. 安装依赖
log_info "安装项目依赖..."

# 根据 Python 版本选择安装方式
if [ "$PYTHON_MINOR" -ge 14 ]; then
    log_warn "检测到 Python 3.14+，使用预编译包安装"
    pip install --only-binary :all: -r requirements.txt
else
    pip install -r requirements.txt
fi

log_info "依赖安装完成"

# 6. 检查环境变量
log_info "检查环境变量..."

if [ ! -f ".env" ]; then
    log_warn ".env 文件不存在，将使用默认配置"
    log_warn "如需配置 API Key 等信息，请创建 .env 文件"
else
    log_info ".env 文件已存在"
fi

# 7. 初始化数据库
log_info "初始化数据库..."
log_info "数据库将在首次启动时自动创建"

# 8. 询问是否立即启动服务
echo ""
log_info "部署完成！"
echo ""
echo "=========================================="
echo "  部署成功！"
echo "=========================================="
echo ""
echo "启动选项："
echo "  1) 开发模式启动（热重载）"
echo "  2) 生产模式启动（后台运行）"
echo "  3) 仅部署，稍后手动启动"
echo ""
read -p "请选择 (1/2/3): " choice

case $choice in
    1)
        log_info "以开发模式启动服务..."
        python3 run.py
        ;;
    2)
        log_info "以生产模式启动服务..."

        # 检查是否安装了 nohup
        if ! command_exists nohup; then
            log_error "未找到 nohup 命令，无法后台运行"
            log_info "请使用开发模式启动或手动安装 nohup"
            exit 1
        fi

        # 后台启动
        nohup python run.py > app.log 2>&1 &
        PID=$!
        echo $PID > app.pid

        log_info "服务已在后台启动，PID: $PID"
        log_info "日志文件: app.log"
        log_info "停止服务: kill \$(cat app.pid)"
        ;;
    3)
        log_info "部署完成，请手动启动服务"
        echo ""
        echo "手动启动命令："
        echo "  source venv/bin/activate"
        echo "  python run.py"
        ;;
    *)
        log_warn "无效选择，请手动启动服务"
        ;;
esac

echo ""
log_info "访问地址："
echo "  - API 文档: http://localhost:3300/docs"
echo "  - ReDoc: http://localhost:3300/redoc"
echo "  - 健康检查: http://localhost:3300/health"
echo ""
