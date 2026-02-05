# ============================================
# Stage 1: Python Backend Dependencies
# ============================================
# 构建 Python 虚拟环境，安装 FastAPI 后端依赖
FROM python:3.11-slim AS python-builder

WORKDIR /build

COPY workspace/vessel-backend/pyproject.toml ./

# 创建虚拟环境并安装后端依赖
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir \
    fastapi>=0.115.0 \
    uvicorn[standard]>=0.32.0 \
    pydantic>=2.10.0 \
    pydantic-settings>=2.6.0 \
    sqlalchemy>=2.0.36 \
    aiosqlite==0.19.0 \
    greenlet>=3.0.0 \
    python-dotenv==1.0.0 \
    python-multipart==0.0.6 \
    httpx==0.26.0

# ============================================
# Stage 2: Node Frontend Dependencies
# ============================================
# 构建前端 node_modules
FROM node:20-slim AS node-builder

WORKDIR /build

RUN npm config set registry https://registry.npmmirror.com

COPY workspace/vessel-frontend/package.json workspace/vessel-frontend/package-lock.json ./

RUN npm ci && mv node_modules /opt/node_modules

# ============================================
# Stage 3: Final Image
# ============================================
# 最终运行镜像，整合所有依赖
FROM node:20-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    git \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# 复制构建阶段的依赖
COPY --from=python-builder /opt/venv /opt/venv
COPY --from=node-builder /opt/node_modules /opt/node_modules

# 修复 Python 符号链接
RUN ln -sf /usr/bin/python3 /opt/venv/bin/python && \
    ln -sf python /opt/venv/bin/python3

# 安装 uv (Python 包管理器)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /opt/venv/bin/

ENV VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    NODE_PATH=/opt/node_modules \
    NODE_ENV=development \
    PYTHONUNBUFFERED=1 

# 安装 OpenCode 及 LSP 服务器
# - typescript-language-server: TypeScript/JavaScript LSP
# - vscode-langservers-extracted: ESLint LSP
# - basedpyright: Python 类型检查 LSP
# - ruff: Python linter LSP
RUN npm config set registry https://registry.npmmirror.com && \
    npm install -g opencode-ai@1.1.45 oh-my-opencode@3.1.7 \
    @different-ai/opencode-browser \
    typescript typescript-language-server \
    vscode-langservers-extracted && \
    /opt/venv/bin/pip install --no-cache-dir basedpyright ruff

# 创建配置目录
RUN mkdir -p /root/.config/opencode && \
    mkdir -p /root/.claude/skills

# 安装 comment-checker (代码注释检查工具)
RUN mkdir -p /root/.cache/oh-my-opencode/bin && \
    cd /tmp && \
    curl -sL https://github.com/code-yeongyu/go-claude-code-comment-checker/releases/download/v0.7.0/comment-checker_v0.7.0_linux_amd64.tar.gz -o comment-checker.tar.gz && \
    tar -xzf comment-checker.tar.gz && \
    mv comment-checker /root/.cache/oh-my-opencode/bin/ && \
    chmod +x /root/.cache/oh-my-opencode/bin/comment-checker && \
    rm -f comment-checker.tar.gz LICENSE README.md

# 复制配置文件和技能包
COPY ./.config/opencode/ /root/.config/opencode/
COPY ./skills/ /root/.claude/skills/

# 复制工作区代码
COPY ./workspace/ /workspace/

# 清理不需要的本地依赖目录
RUN rm -rf /workspace/vessel-backend/venv && \
    rm -rf /workspace/vessel-frontend/node_modules

RUN chmod +x /workspace/scripts/start-vessel.sh

# 初始化 git 仓库并创建初始 commit，让 OpenCode 识别 worktree 为 /workspace
RUN cd /workspace && \
    git config --global user.email "x" && \
    git config --global user.name "x" && \
    git init && git add -A && git commit -m "init"

LABEL vessel.mounts='[ \
  { \
    "name": "workspace", \
    "mountPath": "/workspace", \
    "volumePath": "/workspace", \
    "description": "Project workspace", \
    "initCopy": true \
  }, \
  { \
    "name": "opencode-storage", \
    "mountPath": "/root/.local/share/opencode/storage", \
    "volumePath": "/root/.local/share/opencode/storage", \
    "description": "OpenCode session data", \
    "initCopy": false \
  } \
]'

EXPOSE 3300 4096 5173

WORKDIR /workspace

CMD ["sh", "-c", "cd /workspace && ./scripts/start-vessel.sh all && exec opencode serve --hostname 0.0.0.0 --port 4096"]
