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
    echo "  backend   - 后台启动后端服务"
    echo "  frontend  - 后台启动前端服务"
    echo "  all       - 后台启动前后端（默认）"
    echo ""
    echo "示例:"
    echo "  $0              # 后台启动前后端"
    echo "  $0 all          # 后台启动前后端"
    echo "  $0 backend      # 后台启动后端"
    echo "  $0 frontend     # 后台启动前端"
    echo ""
    echo "日志文件:"
    echo "  后端日志: $BACKEND_LOG"
    echo "  前端日志: $FRONTEND_LOG"
    echo ""
    echo "PID 文件:"
    echo "  后端 PID: $BACKEND_PID_FILE"
    echo "  前端 PID: $FRONTEND_PID_FILE"
}

start_backend() {
    echo "========================================="
    echo "启动 Vessel Backend (后台模式)"
    echo "========================================="
    
    if [ ! -d "$BACKEND_DIR" ]; then
        echo "错误: 后端项目目录不存在: $BACKEND_DIR"
        return 1
    fi
    
    if [ -f "$BACKEND_PID_FILE" ]; then
        OLD_PID=$(cat "$BACKEND_PID_FILE")
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            echo "警告: 后端服务已在运行 (PID: $OLD_PID)"
            echo "请先使用 stop-vessel.sh 停止服务"
            return 1
        fi
    fi
    
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
    
    # 等待后端服务启动，最多等待 30 秒
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
    echo "启动 Vessel Frontend (后台模式)"
    echo "========================================="
    
    if [ ! -d "$FRONTEND_DIR" ]; then
        echo "错误: 前端项目目录不存在: $FRONTEND_DIR"
        return 1
    fi
    
    if [ -f "$FRONTEND_PID_FILE" ]; then
        OLD_PID=$(cat "$FRONTEND_PID_FILE")
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            echo "警告: 前端服务已在运行 (PID: $OLD_PID)"
            echo "请先使用 stop-vessel.sh 停止服务"
            return 1
        fi
    fi
    
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
        echo "启动 Vessel 前后端项目 (后台模式)"
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
            echo "停止服务: ./stop-vessel.sh all"
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
