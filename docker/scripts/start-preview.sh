#!/bin/bash

# 启动后端服务
if [ -f "/workspace/preview-api/scripts/start-backend.sh" ]; then
    echo "启动后端服务..."
    bash /workspace/preview-api/scripts/start-backend.sh
fi

# 启动前端 Vite
echo "启动前端服务..."
exec npx vite --host 0.0.0.0 --port 5173 --strictPort
