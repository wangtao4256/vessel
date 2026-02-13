# ============================================
# Stage 1: Node Frontend Dependencies
# ============================================
# 构建前端 node_modules
FROM node:20-slim AS node-builder

WORKDIR /build

RUN npm config set registry https://registry.npmmirror.com

COPY workspace/vessel-frontend/package.json workspace/vessel-frontend/package-lock.json ./

RUN npm ci && mv node_modules /opt/node_modules

# ============================================
# Stage 2: Final Image
# ============================================
# 最终运行镜像
FROM node:20-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    vim \
    curl \
    lsof \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# 复制构建阶段的依赖
COPY --from=node-builder /opt/node_modules /opt/node_modules

ENV NODE_PATH=/opt/node_modules \
    NODE_ENV=development
ENV OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=65536
# 安装 OpenCode 及 LSP 服务器
RUN npm config set registry https://registry.npmmirror.com && \
    npm install -g opencode-ai@1.1.50 oh-my-opencode@3.5.0 \
    @different-ai/opencode-browser \
    typescript typescript-language-server \
    vscode-langservers-extracted

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
RUN rm -rf /workspace/vessel-frontend/node_modules

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

EXPOSE 4096 5173

WORKDIR /workspace

CMD ["sh", "-c", "cd /workspace && ./scripts/start-vessel.sh && exec opencode serve --hostname 0.0.0.0 --port 4096"]
