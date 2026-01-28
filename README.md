# OpenCode Vessel 环境 Docker 镜像文档

## 📋 概述

OpenCode Vessel 是一个集成了 OpenCode AI、Vessel 后端和前端的完整开发环境 Docker 镜像。该镜像提供了开箱即用的 AI 辅助编程环境。

## 🏗️ 镜像信息

- **镜像名称**: `opencode-vessel-env:latest`
- **基础镜像**: `node:20-bullseye`
- **架构**: ARM64 (适用于 Apple Silicon)
- **镜像大小**: 约 700MB (压缩后)

## 📦 内置组件

### 系统环境
- Node.js 20
- Python 3 (含 venv 和 pip)
- Git
- Vim
- Curl

### 应用组件
- **OpenCode AI**: 全局安装的 AI 编程助手
- **Vessel Backend**: Python FastAPI 后端服务
- **Vessel Frontend**: 前端开发服务器
- **Comment Checker**: 代码注释检查工具

## 🚀 快速开始

### 1. 加载镜像（如果使用导出的镜像文件）

```bash
# 从压缩文件加载镜像
docker load < opencode-vessel-env_latest.tar.gz
```

### 2. 运行容器

```bash
docker run -d \
  --name opencode-vessel \
  -p 3000:3000 \
  -p 3300:3300 \
  -p 4096:4096 \
  -p 5173:5173 \
  opencode-vessel-env:latest
```

### 3. 访问服务

容器启动后，可以通过以下地址访问各个服务：

- **OpenCode Web UI**: http://localhost:4096
- **Vessel Backend API**: http://localhost:3300
- **Vessel Frontend**: http://localhost:5173
- **OpenCode API**: http://localhost:3000

## 🔌 端口说明

| 端口 | 服务 | 说明 |
|------|------|------|
| 3000 | OpenCode API | OpenCode AI 服务端口 |
| 3300 | Vessel Backend | 后端 API 服务 |
| 4096 | OpenCode Web | OpenCode Web 界面 |
| 5173 | Vessel Frontend | 前端开发服务器 (Vite) |

## 📂 容器内目录结构

```
/workspace/
├── vessel-backend/          # Python 后端项目
│   ├── venv/               # Python 虚拟环境
│   ├── requirements.txt    # Python 依赖
│   └── run.py             # 启动脚本
├── vessel-frontend/         # 前端项目
│   ├── node_modules/       # Node 依赖
│   └── package.json        # 前端配置
├── start-vessel.sh         # Vessel 启动脚本
├── stop-vessel.sh          # Vessel 停止脚本
├── vessel-project-structure.md  # 项目结构文档
└── opencode.log           # OpenCode 日志文件

/root/.config/opencode/
└── opencode.json          # OpenCode 配置文件

/root/.cache/oh-my-opencode/bin/
└── comment-checker        # 注释检查工具
```

## 🛠️ 常用命令

### 容器管理

```bash
# 查看容器日志
docker logs opencode-vessel

# 实时跟踪日志
docker logs -f opencode-vessel

# 停止容器
docker stop opencode-vessel

# 启动已停止的容器
docker start opencode-vessel

# 重启容器
docker restart opencode-vessel

# 删除容器
docker rm -f opencode-vessel
```

### 进入容器

```bash
# 进入容器 bash
docker exec -it opencode-vessel bash

# 查看 OpenCode 日志
docker exec -it opencode-vessel cat /workspace/opencode.log

# 查看容器内进程
docker exec -it opencode-vessel ps aux
```

### 手动启动/停止 Vessel 服务

如果需要在容器内手动管理 Vessel 服务：

```bash
# 进入容器
docker exec -it opencode-vessel bash

# 启动服务
cd /workspace
./start-vessel.sh all          # 启动前后端
./start-vessel.sh backend      # 只启动后端
./start-vessel.sh frontend     # 只启动前端

# 停止服务
./stop-vessel.sh all           # 停止前后端
./stop-vessel.sh backend       # 只停止后端
./stop-vessel.sh frontend      # 只停止前端
```

## ⚙️ 环境变量

容器内置以下环境变量：

```bash
NODE_ENV=development
PYTHONUNBUFFERED=1
```

### Vessel Backend 环境变量

可以通过挂载 `.env` 文件来自定义后端配置：

```bash
docker run -d \
  --name opencode-vessel \
  -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \
  -v $(pwd)/.env:/workspace/vessel-backend/.env \
  opencode-vessel-env:latest
```

`.env` 文件示例：

```env
# 数据库配置
DATABASE_URL=sqlite+aiosqlite:///./data/vessel.db

# 服务器配置
HOST=0.0.0.0
PORT=3300
DEBUG=false

# 应用设置
APP_NAME=vessel-backend
APP_VERSION=1.0.0
LOG_LEVEL=INFO
```

## 💾 数据持久化

### 挂载工作目录

```bash
docker run -d \
  --name opencode-vessel \
  -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \
  -v $(pwd)/workspace:/workspace \
  opencode-vessel-env:latest
```

### 挂载数据库目录

```bash
docker run -d \
  --name opencode-vessel \
  -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \
  -v $(pwd)/data:/workspace/vessel-backend/data \
  opencode-vessel-env:latest
```

## 🔧 OpenCode 配置

容器内的 OpenCode 配置文件位于 `/root/.config/opencode/opencode.json`。

### 配置说明

- **模型**: Claude Sonnet 4.5
- **API 提供商**: New CLI CC AWS
- **插件**: 
  - oh-my-opencode
  - @different-ai/opencode-browser

### 自定义配置

可以通过挂载自定义配置文件：

```bash
docker run -d \
  --name opencode-vessel \
  -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \
  -v $(pwd)/opencode.json:/root/.config/opencode/opencode.json \
  opencode-vessel-env:latest
```

## 🏗️ 构建镜像

如果需要自己构建镜像：

```bash
# 使用提供的构建脚本
./build-opencode-image.sh
```

构建脚本会：
1. 从指定目录复制 vessel-backend 和 vessel-frontend
2. 构建 Docker 镜像
3. 导出镜像为 tar.gz 文件

## 🐛 故障排查

### 容器无法启动

```bash
# 查看容器日志
docker logs opencode-vessel

# 检查端口占用
lsof -i :3000
lsof -i :3300
lsof -i :4096
lsof -i :5173
```

### OpenCode 服务未运行

```bash
# 进入容器检查
docker exec -it opencode-vessel bash

# 查看 OpenCode 日志
cat /workspace/opencode.log

# 手动启动 OpenCode
opencode web --hostname 0.0.0.0
```

### Vessel 服务未启动

```bash
# 进入容器
docker exec -it opencode-vessel bash

# 手动启动服务
cd /workspace
./start-vessel.sh all
```

### 权限问题

如果遇到权限问题，可以使用 root 用户运行：

```bash
docker run -d \
  --name opencode-vessel \
  --user root \
  -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \
  opencode-vessel-env:latest
```

## 📊 资源使用

### 推荐配置

- **CPU**: 2 核心以上
- **内存**: 4GB 以上
- **磁盘**: 10GB 可用空间

### 限制资源使用

```bash
docker run -d \
  --name opencode-vessel \
  --cpus="2" \
  --memory="4g" \
  -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \
  opencode-vessel-env:latest
```

## 🔐 安全注意事项

⚠️ **重要**: 配置文件中包含 API 密钥，请注意：

1. 不要将包含真实 API 密钥的配置文件提交到公共仓库
2. 在生产环境中使用环境变量或密钥管理服务
3. 定期轮换 API 密钥
4. 限制容器的网络访问权限

### 使用环境变量传递 API 密钥

```bash
docker run -d \
  --name opencode-vessel \
  -e ANTHROPIC_API_KEY="your-api-key-here" \
  -p 3000:3000 -p 3300:3300 -p 4096:4096 -p 5173:5173 \
  opencode-vessel-env:latest
```

## 📝 更新日志

### v1.0.0 (当前版本)
- 初始版本
- 集成 OpenCode AI
- 集成 Vessel 前后端
- 支持 ARM64 架构

## 🤝 支持与反馈

如有问题或建议，请联系项目维护者。

## 📄 许可证

请参考项目许可证文件。
