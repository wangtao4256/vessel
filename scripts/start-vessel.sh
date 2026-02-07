#!/bin/bash

PREVIEW_API_DIR="/preview-api"
LOG_DIR="/var/log/vessel"
PREVIEW_API_LOG="$LOG_DIR/preview-api.log"
PREVIEW_API_PID_FILE="$LOG_DIR/preview-api.pid"

PREVIEW_API_PORT=3300

mkdir -p "$LOG_DIR"

stop_backend() {
    echo "停止已有后端服务..."
    
    FOUND=0
    
    if [ -f "$PREVIEW_API_PID_FILE" ]; then
        PID=$(cat "$PREVIEW_API_PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "  通过 PID 文件停止进程: $PID"
            kill $PID 2>/dev/null
            sleep 1
            kill -9 $PID 2>/dev/null
            FOUND=1
        fi
        rm -f "$PREVIEW_API_PID_FILE"
    fi
    
    if command -v lsof >/dev/null 2>&1; then
        PORT_PIDS=$(lsof -ti:$PREVIEW_API_PORT 2>/dev/null)
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

start_backend() {
    echo "========================================="
    echo "启动 Preview API"
    echo "========================================="
    
    if [ ! -d "$PREVIEW_API_DIR" ]; then
        echo "错误: 项目目录不存在: $PREVIEW_API_DIR"
        return 1
    fi
    
    stop_backend
    
    cd "$PREVIEW_API_DIR" || return 1
    
    echo "使用端口: $PREVIEW_API_PORT"
    
    echo "启动后端服务器..."
    nohup uvicorn app.main:app --host 0.0.0.0 --port $PREVIEW_API_PORT --reload >> "$PREVIEW_API_LOG" 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > "$PREVIEW_API_PID_FILE"
    
    echo "等待后端服务启动..."
    for i in $(seq 1 15); do
        if curl -s http://localhost:$PREVIEW_API_PORT/health > /dev/null 2>&1; then
            echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"
            echo "   日志文件: $PREVIEW_API_LOG"
            echo "   访问地址: http://localhost:$PREVIEW_API_PORT"
            return 0
        fi
        sleep 1
    done
    
    echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"
    echo "   日志文件: $PREVIEW_API_LOG"
    return 0
}

start_backend
