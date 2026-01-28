#!/bin/bash

BACKEND_DIR="/workspace/vessel-backend"
FRONTEND_DIR="/workspace/vessel-frontend"

show_usage() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  backend   - 只停止后端服务"
    echo "  frontend  - 只停止前端服务"
    echo "  all       - 同时停止前后端（默认）"
    echo ""
    echo "示例:"
    echo "  $0              # 停止前后端"
    echo "  $0 all          # 停止前后端"
    echo "  $0 backend      # 只停止后端"
    echo "  $0 frontend     # 只停止前端"
}

stop_backend() {
    echo "========================================="
    echo "停止 Vessel Backend"
    echo "========================================="
    
    BACKEND_PIDS=$(ps aux | grep "[p]ython.*run.py" | awk '{print $2}')
    
    if [ -z "$BACKEND_PIDS" ]; then
        echo "未找到运行中的后端服务"
        return 0
    fi
    
    echo "找到后端进程: $BACKEND_PIDS"
    for PID in $BACKEND_PIDS; do
        echo "正在停止进程 $PID..."
        kill $PID 2>/dev/null
        sleep 2
        
        if ps -p $PID > /dev/null 2>&1; then
            echo "进程 $PID 未响应，强制终止..."
            kill -9 $PID 2>/dev/null
        fi
    done
    
    echo "✅ 后端服务已停止"
}

stop_frontend() {
    echo "========================================="
    echo "停止 Vessel Frontend"
    echo "========================================="
    
    FRONTEND_PIDS=$(ps aux | grep -E "[n]pm.*run.*dev|[v]ite" | grep -v grep | awk '{print $2}')
    
    if [ -z "$FRONTEND_PIDS" ]; then
        echo "未找到运行中的前端服务"
        return 0
    fi
    
    echo "找到前端进程: $FRONTEND_PIDS"
    for PID in $FRONTEND_PIDS; do
        echo "正在停止进程 $PID..."
        kill $PID 2>/dev/null
        sleep 2
        
        if ps -p $PID > /dev/null 2>&1; then
            echo "进程 $PID 未响应，强制终止..."
            kill -9 $PID 2>/dev/null
        fi
    done
    
    NODE_PIDS=$(lsof -ti:5173 2>/dev/null)
    if [ ! -z "$NODE_PIDS" ]; then
        echo "清理端口 5173 上的进程: $NODE_PIDS"
        kill $NODE_PIDS 2>/dev/null
    fi
    
    echo "✅ 前端服务已停止"
}

MODE="${1:-all}"

case "$MODE" in
    backend)
        stop_backend
        ;;
    frontend)
        stop_frontend
        ;;
    all)
        echo "========================================="
        echo "停止 Vessel 前后端项目"
        echo "========================================="
        echo ""
        
        stop_backend
        echo ""
        stop_frontend
        
        echo ""
        echo "✅ 所有服务已停止"
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
