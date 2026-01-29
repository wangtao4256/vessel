FROM node:20-bullseye

RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    git \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN npm config set registry https://registry.npmmirror.com

RUN npm install -g opencode-ai

RUN mkdir -p /root/.config/opencode
RUN mkdir -p /root/.claude/skills

RUN mkdir -p /root/.cache/oh-my-opencode/bin && \
    cd /tmp && \
    curl -sL https://github.com/code-yeongyu/go-claude-code-comment-checker/releases/download/v0.7.0/comment-checker_v0.7.0_linux_arm64.tar.gz -o comment-checker.tar.gz && \
    tar -xzf comment-checker.tar.gz && \
    mv comment-checker /root/.cache/oh-my-opencode/bin/ && \
    chmod +x /root/.cache/oh-my-opencode/bin/comment-checker && \
    rm -f comment-checker.tar.gz LICENSE README.md

COPY opencode.json /root/.config/opencode/opencode.json
COPY ./skills/vessel-lite-proxy-skill /root/.claude/skills/vessel-lite-proxy
COPY ./skills/ui-ux-pro-max /root/.claude/skills/ui-ux-pro-max
COPY ./start-vessel.sh /workspace/scripts/start-vessel.sh
COPY ./stop-vessel.sh /workspace/scripts/stop-vessel.sh
COPY ./docs/vessel-project-structure.md /workspace/docs/vessel-project-structure.md
COPY ./docs/global-identity.md /workspace/docs/global-identity.md

COPY vessel-backend /workspace/vessel-backend
COPY vessel-frontend /workspace/vessel-frontend

RUN chmod +x /workspace/scripts/start-vessel.sh /workspace/scripts/stop-vessel.sh
WORKDIR /workspace/vessel-backend
RUN pip3 install --no-cache-dir -r requirements.txt

WORKDIR /workspace/vessel-frontend
RUN npm install

WORKDIR /workspace

ENV NODE_ENV=development
ENV PYTHONUNBUFFERED=1


LABEL vessel.mounts='[{"name":"root","path":"/root","size":"1Gi","description":"OpenCode config, Claude skills, cache"},{"name":"workspace","path":"/workspace","size":"1Gi","description":"Project code, database, logs"}]'

EXPOSE 3000 3300 4096 5173

CMD ["sh", "-c", "rm -f /workspace/logs/*.pid && ./scripts/start-vessel.sh all && nohup opencode web --hostname 0.0.0.0 > /workspace/opencode.log 2>&1 & tail -f /dev/null"]
