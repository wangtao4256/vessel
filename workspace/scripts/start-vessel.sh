#!/bin/bash

FRONTEND_DIR="/workspace/vessel-frontend"
LOG_DIR="/workspace/logs"
FRONTEND_LOG="$LOG_DIR/frontend.log"
FRONTEND_PORT=5173

BASE_NODE_MODULES="/opt/node_modules"
OPENCODE_CONFIG="/root/.config/opencode/opencode.json"

ENV_FILE="/workspace/.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    . "$ENV_FILE"
    set +a
fi

mkdir -p "$LOG_DIR"

init_opencode_config() {
    echo "========================================="
    echo "初始化 OpenCode 配置"
    echo "========================================="

    echo "请求: POST ${LITELLM_API_BASE}/key/generate"
    RESPONSE=$(curl -s "${LITELLM_API_BASE}/key/generate" \
        -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"models\":[\"${LITELLM_MODEL}\"],\"max_budget\":${LITELLM_BUDGET},\"budget_duration\":\"${LITELLM_BUDGET_DURATION}\"}")
    echo "响应: $RESPONSE"

    API_KEY=$(echo "$RESPONSE" | node -e "
        let d='';
        process.stdin.on('data',c=>d+=c);
        process.stdin.on('end',()=>{
            try{console.log(JSON.parse(d).key)}
            catch(e){process.exit(1)}
        });
    ")

    if [ -z "$API_KEY" ]; then
        echo "错误: 获取 API Key 失败"
        echo "响应: $RESPONSE"
        return 1
    fi

    echo "API Key 获取成功: ${API_KEY:0:10}..."

    OPENCODE_CONFIG="$OPENCODE_CONFIG" \
    LITELLM_API_BASE="$LITELLM_API_BASE" \
    API_KEY="$API_KEY" \
    node -e "
        const fs = require('fs');
        const cfgPath = process.env.OPENCODE_CONFIG;
        const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'));
        if (!cfg.provider.anthropic.options) cfg.provider.anthropic.options = {};
        cfg.provider.anthropic.options.baseURL = process.env.LITELLM_API_BASE + '/v1';
        cfg.provider.anthropic.options.apiKey = process.env.API_KEY;
        fs.writeFileSync(cfgPath, JSON.stringify(cfg, null, 2));
    "

    if [ $? -eq 0 ]; then
        echo "OpenCode 配置已更新"
    else
        echo "错误: 更新配置文件失败"
        return 1
    fi
}

show_usage() {
    echo "用法: $0"
    echo ""
    echo "启动前端开发服务器"
}

get_port_pids() {
    local PORT=$1
    if command -v lsof >/dev/null 2>&1; then
        lsof -ti:$PORT 2>/dev/null
    elif command -v ss >/dev/null 2>&1; then
        ss -tlnp "sport = :$PORT" 2>/dev/null | grep -oP 'pid=\K[0-9]+' | sort -u
    elif [ -d /proc ]; then
        local HEX_PORT=$(printf '%X' $PORT)
        awk -v hp="$HEX_PORT" '$2 ~ ":"hp"$" && $4 == "0A" {print $10}' /proc/net/tcp 2>/dev/null | sort -u | grep -v '^0$'
    fi
}

stop_frontend() {
    echo "停止已有前端服务..."

    rm -f "$LOG_DIR/frontend.pid"

    local PIDS
    PIDS=$(get_port_pids $FRONTEND_PORT)

    if [ -z "$PIDS" ]; then
        echo "  端口 $FRONTEND_PORT 无占用，无需清理"
        return 0
    fi

    for PID in $PIDS; do
        echo "  杀掉端口 $FRONTEND_PORT 上的进程: $PID"
        kill $PID 2>/dev/null
    done
    sleep 1
    for PID in $PIDS; do
        kill -9 $PID 2>/dev/null
    done

    local REMAINING
    REMAINING=$(get_port_pids $FRONTEND_PORT)
    if [ -n "$REMAINING" ]; then
        echo "  错误: 端口 $FRONTEND_PORT 仍被占用 (PID: $REMAINING)，可能是非前端进程"
        return 1
    fi

    echo "  前端服务已停止"
}

start_frontend() {
    echo "========================================="
    echo "启动 Vessel Frontend"
    echo "========================================="
    
    if [ ! -d "$FRONTEND_DIR" ]; then
        echo "错误: 前端项目目录不存在: $FRONTEND_DIR"
        return 1
    fi
    
    stop_frontend || return 1
    
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
    
    echo "启动前端开发服务器..."
    nohup npm run dev -- --host 0.0.0.0 >> "$FRONTEND_LOG" 2>&1 &
    
    echo "等待前端服务启动..."
    for i in $(seq 1 30); do
        if curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
            echo "前端服务已启动"
            echo "   日志文件: $FRONTEND_LOG"
            echo "   访问地址: http://localhost:$FRONTEND_PORT"
            return 0
        fi
        sleep 1
    done
    
    echo "前端服务启动超时，请查看日志: $FRONTEND_LOG"
    return 1
}

case "${1:-start}" in
    -h|--help)
        show_usage
        ;;
    *)
        init_opencode_config || exit 1
        start_frontend
        ;;
esac
