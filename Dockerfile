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
COPY start-vessel.sh /workspace/start-vessel.sh
COPY stop-vessel.sh /workspace/stop-vessel.sh
RUN chmod +x /workspace/start-vessel.sh /workspace/stop-vessel.sh
COPY vessel-backend /workspace/vessel-backend
WORKDIR /workspace/vessel-backend
RUN pip3 install --no-cache-dir -r requirements.txt

COPY vessel-frontend /workspace/vessel-frontend
WORKDIR /workspace/vessel-frontend
COPY vessel-project-structure.md /workspace/vessel-project-structure.md
RUN npm install

WORKDIR /workspace

ENV NODE_ENV=development
ENV PYTHONUNBUFFERED=1

EXPOSE 3000 3300 4096 5173

CMD ["sh", "-c", "nohup opencode web --hostname 0.0.0.0 > /workspace/opencode.log 2>&1 & tail -f /dev/null"]
