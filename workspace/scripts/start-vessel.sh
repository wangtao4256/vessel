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
    echo "初始化 OpenCode 配置"

    EXISTING=$(node -e "
        const fs = require('fs');
        try {
            const cfg = JSON.parse(fs.readFileSync('$OPENCODE_CONFIG', 'utf8'));
            const opts = cfg.provider && cfg.provider.anthropic && cfg.provider.anthropic.options;
            if (opts && opts.baseURL && opts.apiKey) { console.log('ok'); }
        } catch(e) {}
    ")
    if [ "$EXISTING" = "ok" ]; then
        return 0
    fi

    RESPONSE=$(curl -s --connect-timeout 5 --max-time 15 "${LITELLM_API_BASE}/key/generate" \
        -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"models\":[\"${LITELLM_MODEL}\"],\"max_budget\":${LITELLM_BUDGET},\"budget_duration\":\"${LITELLM_BUDGET_DURATION}\"}")

    if [ $? -ne 0 ]; then
        echo "错误: 无法连接 LiteLLM 服务 (${LITELLM_API_BASE})"
        return 1
    fi

    API_KEY=$(echo "$RESPONSE" | node -e "
        let d='';
        process.stdin.on('data',c=>d+=c);
        process.stdin.on('end',()=>{
            try{console.log(JSON.parse(d).key)}
            catch(e){process.exit(1)}
        });
    ")

    if [ -z "$API_KEY" ]; then
        echo "错误: 从 LiteLLM 获取 API Key 失败，响应: ${RESPONSE}"
        return 1
    fi

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
        echo "错误: 写入 OpenCode 配置文件失败 ($OPENCODE_CONFIG)"
        return 1
    fi
}

show_usage() {
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
        local INODES
        INODES=$(awk -v hp="$HEX_PORT" '$2 ~ ":"hp"$" && $4 == "0A" {print $10}' /proc/net/tcp 2>/dev/null | sort -u | grep -v '^0$')
        for INODE in $INODES; do
            find /proc/[0-9]*/fd -lname "socket:\[$INODE\]" 2>/dev/null | grep -oP '/proc/\K[0-9]+' | sort -u
        done
    fi
}

stop_frontend() {
    echo "停止已有前端服务..."

    rm -f "$LOG_DIR/frontend.pid"

    local PIDS
    PIDS=$(get_port_pids $FRONTEND_PORT)

    if [ -z "$PIDS" ]; then
        return 0
    fi

    for PID in $PIDS; do
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

    if [ ! -d "$FRONTEND_DIR" ]; then
        echo "错误: 前端目录不存在 ($FRONTEND_DIR)"
        return 1
    fi
    
    stop_frontend || return 1
    
    cd "$FRONTEND_DIR" || return 1
    
    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        if [ -d "$BASE_NODE_MODULES" ]; then
            ln -s "$BASE_NODE_MODULES" "$FRONTEND_DIR/node_modules"
        fi
    fi
    
    echo "启动前端开发服务器..."
    nohup npm run dev -- --host 0.0.0.0 >> "$FRONTEND_LOG" 2>&1 &
    
    for i in $(seq 1 30); do
        if curl -s --connect-timeout 2 http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
            echo "前端服务已启动"
            return 0
        fi
        sleep 1
    done
    
    echo "错误: 前端服务启动超时 (30s)，请检查日志: $FRONTEND_LOG"
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
