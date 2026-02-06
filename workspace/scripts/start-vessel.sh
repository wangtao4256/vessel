#!/bin/bash

FRONTEND_DIR="/workspace/vessel-frontend"
LOG_DIR="/workspace/logs"
FRONTEND_LOG="$LOG_DIR/frontend.log"
FRONTEND_PID_FILE="$LOG_DIR/frontend.pid"
FRONTEND_PORT_FILE="$LOG_DIR/frontend.port"

BASE_NODE_MODULES="/opt/node_modules"
PORT_START=5173
PORT_END=5183

mkdir -p "$LOG_DIR"

find_available_port() {
    for port in $(seq $PORT_START $PORT_END); do
        if ! lsof -i:$port >/dev/null 2>&1; then
            echo $port
            return 0
        fi
    done
    echo ""
    return 1
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
    
    if [ $FOUND -eq 0 ]; then
        echo "  未找到运行中的前端服务"
    else
        echo "  ✅ 前端服务已停止"
    fi
}

start_frontend() {
    echo "========================================="
    echo "启动 Vessel Frontend"
    echo "========================================="
    
    if [ ! -d "$FRONTEND_DIR" ]; then
        echo "错误: 前端项目目录不存在: $FRONTEND_DIR"
        return 1
    fi
    
    stop_frontend
    
    cd "$FRONTEND_DIR" || return 1
    
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
    
    FRONTEND_PORT=$(find_available_port)
    if [ -z "$FRONTEND_PORT" ]; then
        echo "❌ 无可用端口 ($PORT_START-$PORT_END)"
        return 1
    fi
    
    echo "使用端口: $FRONTEND_PORT"
    echo $FRONTEND_PORT > "$FRONTEND_PORT_FILE"
    
    echo "启动前端开发服务器..."
    nohup npm run dev -- --host 0.0.0.0 --port $FRONTEND_PORT >> "$FRONTEND_LOG" 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > "$FRONTEND_PID_FILE"
    
    echo "等待前端服务启动..."
    for i in $(seq 1 30); do
        if curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
            echo "✅ 前端服务已启动 (PID: $FRONTEND_PID)"
            echo "   日志文件: $FRONTEND_LOG"
            echo "   访问地址: http://localhost:$FRONTEND_PORT"
            return 0
        fi
        sleep 1
    done
    
    echo "❌ 前端服务启动超时，请查看日志: $FRONTEND_LOG"
    return 1
}

start_frontend
