# ============================================
# Stage 1: Python Backend Dependencies
# ============================================
FROM python:3.11-slim AS python-builder

WORKDIR /build

COPY vessel-api/pyproject.toml ./

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
FROM node:20-slim AS node-builder

WORKDIR /build

RUN npm config set registry https://registry.npmmirror.com

COPY workspace/default/vessel-frontend/package.json workspace/default/vessel-frontend/package-lock.json ./

RUN npm ci && mv node_modules /opt/node_modules

# ============================================
# Stage 3: Final Image
# ============================================
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    git \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 docker CLI (仅客户端，约 50MB)
RUN curl -fsSL https://download.docker.com/linux/static/stable/$(uname -m)/docker-27.0.3.tgz | \
    tar -xz --strip-components=1 -C /usr/local/bin docker/docker

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
    npm install -g opencode-ai@1.1.45 oh-my-opencode@3.1.7 \
    @different-ai/opencode-browser \
    typescript typescript-language-server \
    vscode-langservers-extracted && \
    /opt/venv/bin/pip install --no-cache-dir basedpyright ruff

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

COPY ./vessel-api/ /vessel-api/
COPY ./vessel-api/.env /vessel-api/.env

COPY ./workspace/ /workspace/

RUN rm -rf /workspace/default/vessel-frontend/node_modules

RUN cd /workspace/default/preview-api && \
    python3 -m venv venv && \
    ./venv/bin/pip install --no-cache-dir -r requirements.txt

RUN chmod +x /vessel-api/scripts/start-backend.sh && \
    chmod +x /workspace/default/vessel-frontend/scripts/start-vessel.sh

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

CMD ["sh", "-c", "/workspace/default/vessel-frontend/scripts/start-vessel.sh && /vessel-api/scripts/start-backend.sh && exec opencode serve --hostname 0.0.0.0 --port 4096"]
