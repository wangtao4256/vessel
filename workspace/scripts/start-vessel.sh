#!/bin/bash

BACKEND_DIR="/workspace/vessel-backend"
FRONTEND_DIR="/workspace/vessel-frontend"
LOG_DIR="/workspace/logs"
BACKEND_LOG="$LOG_DIR/backend.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"
BACKEND_PID_FILE="$LOG_DIR/backend.pid"
FRONTEND_PID_FILE="$LOG_DIR/frontend.pid"

# 预装依赖路径
BASE_VENV="/opt/venv"
BASE_NODE_MODULES="/opt/node_modules"

mkdir -p "$LOG_DIR"

show_usage() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  backend   - 启动后端服务（会先停止已有服务）"
    echo "  frontend  - 启动前端服务（会先停止已有服务）"
    echo "  all       - 启动前后端（默认，会先停止已有服务）"
    echo ""
    echo "示例:"
    echo "  $0              # 启动前后端"
    echo "  $0 all          # 启动前后端"
    echo "  $0 backend      # 只启动后端"
    echo "  $0 frontend     # 只启动前端"
}

# ========================================
# 停止函数
# ========================================

stop_backend() {
    echo "停止已有后端服务..."
    
    FOUND=0
    
    # 方式1: 通过 PID 文件 (兼容精简容器)
    if [ -f "$BACKEND_PID_FILE" ]; then
        PID=$(cat "$BACKEND_PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "  通过 PID 文件停止进程: $PID"
            kill $PID 2>/dev/null
            sleep 1
            kill -9 $PID 2>/dev/null
            FOUND=1
        fi
        rm -f "$BACKEND_PID_FILE"
    fi
    
    # 方式2: 通过进程名查找 (需要 ps 命令)
    if command -v ps >/dev/null 2>&1; then
        BACKEND_PIDS=$(ps aux 2>/dev/null | grep "[p]ython.*run.py" | awk '{print $2}')
        if [ ! -z "$BACKEND_PIDS" ]; then
            for PID in $BACKEND_PIDS; do
                echo "  通过进程名停止: $PID"
                kill $PID 2>/dev/null
                sleep 1
                kill -9 $PID 2>/dev/null
                FOUND=1
            done
        fi
    fi
    
    # 方式3: 清理端口 (需要 lsof 命令)
    if command -v lsof >/dev/null 2>&1; then
        PORT_PIDS=$(lsof -ti:3300 2>/dev/null)
        if [ ! -z "$PORT_PIDS" ]; then
            echo "  通过端口清理: $PORT_PIDS"
            kill $PORT_PIDS 2>/dev/null
            FOUND=1
        fi
    fi
    
    if [ $FOUND -eq 0 ]; then
        echo "  未找到运行中的后端服务"
    else
        echo "  ✅ 后端服务已停止"
    fi
}

stop_frontend() {
    echo "停止已有前端服务..."
    
    FOUND=0
    
    if [ -f "$FRONTEND_PID_FILE" ]; then
        PID=$(cat "$FRONTEND_PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "  通过 PID 文件停止进程: $PID"
            kill $PID 2>/dev/null
            sleep 1
            kill -9 $PID 2>/dev/null
            FOUND=1
        fi
        rm -f "$FRONTEND_PID_FILE"
    fi
    
    if command -v ps >/dev/null 2>&1; then
        FRONTEND_PIDS=$(ps aux 2>/dev/null | grep -E "[n]pm.*run.*dev|[v]ite" | grep -v grep | awk '{print $2}')
        if [ ! -z "$FRONTEND_PIDS" ]; then
            for PID in $FRONTEND_PIDS; do
                echo "  通过进程名停止: $PID"
                kill $PID 2>/dev/null
                sleep 1
                kill -9 $PID 2>/dev/null
                FOUND=1
            done
        fi
    fi
    
    if command -v lsof >/dev/null 2>&1; then
        PORT_PIDS=$(lsof -ti:5173 2>/dev/null)
        if [ ! -z "$PORT_PIDS" ]; then
            echo "  通过端口清理: $PORT_PIDS"
            kill $PORT_PIDS 2>/dev/null
            FOUND=1
        fi
    fi
    
    if [ $FOUND -eq 0 ]; then
        echo "  未找到运行中的前端服务"
    else
        echo "  ✅ 前端服务已停止"
    fi
}

# ========================================
# 启动函数
# ========================================

start_backend() {
    echo "========================================="
    echo "启动 Vessel Backend"
    echo "========================================="
    
    if [ ! -d "$BACKEND_DIR" ]; then
        echo "错误: 后端项目目录不存在: $BACKEND_DIR"
        return 1
    fi
    
    # 先停止已有服务
    stop_backend
    
    cd "$BACKEND_DIR" || return 1
    
    # 优先使用用户自定义 .venv，否则用预装的
    if [ -d "$BACKEND_DIR/.venv" ]; then
        echo "使用用户 venv: $BACKEND_DIR/.venv"
        source "$BACKEND_DIR/.venv/bin/activate"
    elif [ -d "$BASE_VENV" ]; then
        echo "使用预装 venv: $BASE_VENV"
        export VIRTUAL_ENV="$BASE_VENV"
        export PATH="$BASE_VENV/bin:$PATH"
    else
        echo "警告: 未找到虚拟环境，尝试使用系统 Python"
    fi
    
    echo "Python: $(which python)"
    
    echo "启动后端服务..."
    nohup python run.py >> "$BACKEND_LOG" 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > "$BACKEND_PID_FILE"
    
    # 等待后端服务启动
    echo "等待后端服务启动..."
    for i in $(seq 1 30); do
        if curl -s http://localhost:3300/health > /dev/null 2>&1; then
            echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"
            echo "   日志文件: $BACKEND_LOG"
            echo "   访问地址: http://localhost:3300"
            return 0
        fi
        sleep 1
    done
    
    echo "❌ 后端服务启动超时，请查看日志: $BACKEND_LOG"
    return 1
}

start_frontend() {
    echo "========================================="
    echo "启动 Vessel Frontend"
    echo "========================================="
    
    if [ ! -d "$FRONTEND_DIR" ]; then
        echo "错误: 前端项目目录不存在: $FRONTEND_DIR"
        return 1
    fi
    
    # 先停止已有服务
    stop_frontend
    
    cd "$FRONTEND_DIR" || return 1
    
    # 优先使用用户 node_modules，否则创建软链接到预装的
    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        if [ -d "$BASE_NODE_MODULES" ]; then
            echo "创建软链接到预装 node_modules: $BASE_NODE_MODULES"
            ln -s "$BASE_NODE_MODULES" "$FRONTEND_DIR/node_modules"
        else
            echo "警告: 未找到预装 node_modules，需要手动安装依赖"
        fi
    else
        echo "使用用户 node_modules"
    fi
    
    echo "启动前端开发服务器..."
    nohup npm run dev -- --host 0.0.0.0 >> "$FRONTEND_LOG" 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > "$FRONTEND_PID_FILE"
    
    # 等待前端服务启动
    echo "等待前端服务启动..."
    for i in $(seq 1 30); do
        if curl -s http://localhost:5173 > /dev/null 2>&1; then
            echo "✅ 前端服务已启动 (PID: $FRONTEND_PID)"
            echo "   日志文件: $FRONTEND_LOG"
            echo "   访问地址: http://localhost:5173"
            return 0
        fi
        sleep 1
    done
    
    echo "❌ 前端服务启动超时，请查看日志: $FRONTEND_LOG"
    return 1
}

# ========================================
# 主逻辑
# ========================================

MODE="${1:-all}"

case "$MODE" in
    backend)
        start_backend
        ;;
    frontend)
        start_frontend
        ;;
    all)
        echo "========================================="
        echo "启动 Vessel 前后端项目"
        echo "========================================="
        echo ""
        
        start_backend
        BACKEND_STATUS=$?
        
        echo ""
        
        start_frontend
        FRONTEND_STATUS=$?
        
        echo ""
        echo "========================================="
        if [ $BACKEND_STATUS -eq 0 ] && [ $FRONTEND_STATUS -eq 0 ]; then
            echo "✅ 前后端服务已全部启动"
            echo ""
            echo "服务信息:"
            echo "  后端 PID: $(cat $BACKEND_PID_FILE 2>/dev/null || echo '未知')"
            echo "  前端 PID: $(cat $FRONTEND_PID_FILE 2>/dev/null || echo '未知')"
            echo ""
            echo "访问地址:"
            echo "  后端: http://localhost:3300"
            echo "  前端: http://localhost:5173"
            echo ""
            echo "日志文件:"
            echo "  后端: $BACKEND_LOG"
            echo "  前端: $FRONTEND_LOG"
            echo ""
            echo "查看日志: tail -f $BACKEND_LOG"
            echo "         tail -f $FRONTEND_LOG"
        else
            echo "❌ 部分服务启动失败，请查看日志文件"
            exit 1
        fi
        echo "========================================="
        ;;
    -h|--help)
        show_usage
        ;;
    *)
        echo "错误: 未知选项 '$MODE'"
        echo ""
        show_usage
        exit 1
        ;;
esac
