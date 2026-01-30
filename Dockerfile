# ============================================
# Stage 1: Python Dependencies
# ============================================
FROM python:3.11-slim AS python-builder

WORKDIR /build

COPY workspace/vessel-backend/pyproject.toml ./

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
# Stage 2: Node Dependencies
# ============================================
FROM node:20-slim AS node-builder

WORKDIR /build

RUN npm config set registry https://registry.npmmirror.com

COPY workspace/vessel-frontend/package.json workspace/vessel-frontend/package-lock.json ./

RUN npm ci && mv node_modules /opt/node_modules

# ============================================
# Stage 3: Final Image
# ============================================
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    python3 \
    git \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY --from=python-builder /opt/venv /opt/venv
COPY --from=node-builder /opt/node_modules /opt/node_modules

RUN ln -sf /usr/bin/python3 /opt/venv/bin/python && \
    ln -sf python /opt/venv/bin/python3

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /opt/venv/bin/

ENV VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    NODE_PATH=/opt/node_modules \
    NODE_ENV=development \
    PYTHONUNBUFFERED=1

RUN npm config set registry https://registry.npmmirror.com && \
    npm install -g opencode-ai oh-my-opencode @different-ai/opencode-browser \
    typescript typescript-language-server

RUN /opt/venv/bin/pip install --no-cache-dir python-lsp-server

RUN mkdir -p /root/.config/opencode && \
    mkdir -p /root/.claude/skills

RUN mkdir -p /root/.cache/oh-my-opencode/bin && \
    cd /tmp && \
    curl -sL https://github.com/code-yeongyu/go-claude-code-comment-checker/releases/download/v0.7.0/comment-checker_v0.7.0_linux_amd64.tar.gz -o comment-checker.tar.gz && \
    tar -xzf comment-checker.tar.gz && \
    mv comment-checker /root/.cache/oh-my-opencode/bin/ && \
    chmod +x /root/.cache/oh-my-opencode/bin/comment-checker && \
    rm -f comment-checker.tar.gz LICENSE README.md

COPY ./.config/opencode/ /root/.config/opencode/
COPY ./skills/ /root/.claude/skills/

COPY ./workspace/ /workspace/

RUN rm -rf /workspace/vessel-backend/venv && \
    rm -rf /workspace/vessel-frontend/node_modules

RUN chmod +x /workspace/scripts/start-vessel.sh /workspace/scripts/stop-vessel.sh

# 初始化 git 仓库并创建初始 commit，让 OpenCode 识别 worktree 为 /workspace
RUN cd /workspace && \
    git config --global user.email "x" && \
    git config --global user.name "x" && \
    git init && git add -A && git commit -m "init"

LABEL vessel.mounts='[ \
  { \
    "name": "workspace", \
    "mountPath": "/workspace", \
    "volumePath": "", \
    "description": "Project workspace" \
  }, \
  { \
    "name": "opencode-storage", \
    "mountPath": "/root/.local/share/opencode/storage", \
    "volumePath": "opencode-storage", \
    "description": "OpenCode session data" \
  } \
]'

EXPOSE 3300 4096 5173

WORKDIR /workspace

CMD ["sh", "-c", "cd /workspace && ./scripts/start-vessel.sh all && exec opencode serve --hostname 0.0.0.0 --port 4096"]
