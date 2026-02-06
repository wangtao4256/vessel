# Vessel 全局 Prompt 注入配置

## TL;DR

> **Quick Summary**: 将项目规则从 AGENTS.md 和 prompt_append 迁移到 OpenCode 原生的 instructions 配置
> 
> **Deliverables**:
> - 创建 `docs/vessel-rules.md`
> - 修改 `opencode.jsonc` 添加 instructions
> - 清理 `oh-my-opencode.jsonc` 中的 prompt_append
> - 删除 `AGENTS.md`
> - 重新构建 Docker 镜像
> 
> **Estimated Effort**: Quick
> **Parallel Execution**: NO - sequential

---

## Context

### Original Request
用户希望将项目规则改为全局文件注入方式，不依赖 AGENTS.md（不稳定）和 prompt_append（分散）。

### Research Findings
- OpenCode 原生支持 `instructions` 配置，可以直接注入 md 文件
- 配置格式：`"instructions": ["path/to/file.md"]`
- 这是最稳定的全局注入方式

---

## Work Objectives

### Core Objective
使用 OpenCode 原生 instructions 配置实现全局 prompt 注入

### Concrete Deliverables
- `docs/vessel-rules.md` - 工作目录约束 + 输出规则
- `opencode.jsonc` - 添加 instructions 字段
- `oh-my-opencode.jsonc` - 移除 prompt_append
- 删除 `AGENTS.md`

### Definition of Done
- [x] instructions 配置生效
- [x] 容器内配置文件正确

---

## TODOs

- [x] 1. 创建 docs/vessel-rules.md

  **What to do**:
  创建文件，内容如下：
  ```markdown
  # Vessel 项目规则

  ## 工作目录

  - 前端代码：`/workspace/vessel-frontend/src/`
  - 后端代码：`/workspace/vessel-backend/`
  - 禁止在其他目录创建文件

  ## 输出规则

  **允许**：中文回复、简洁说明、引导点击"查看作品"

  **禁止暴露**：端口号、localhost 地址、数据库路径、API 地址、技术实现细节
  ```

  **References**:
  - `docs/global-identity.md` - 已有的身份定义文件，保留

  **Acceptance Criteria**:
  - [x] 文件存在：`ls docs/vessel-rules.md`
  - [x] 内容包含工作目录和输出规则

  **Commit**: NO (与下一个任务一起提交)

---

- [x] 2. 修改 opencode.jsonc 添加 instructions

  **What to do**:
  在 `opencode.jsonc` 中添加 instructions 字段：
  ```jsonc
  {
    "instructions": [
      "docs/global-identity.md",
      "docs/vessel-rules.md"
    ],
    // ... 其他配置保持不变
  }
  ```

  **References**:
  - `opencode.jsonc` - 当前配置文件

  **Acceptance Criteria**:
  - [x] `grep -q "instructions" opencode.jsonc` 返回成功
  - [x] JSON 语法正确

  **Commit**: NO (与下一个任务一起提交)

---

- [x] 3. 删除 oh-my-opencode.jsonc 中的 prompt_append

  **What to do**:
  移除 `categories.visual-engineering.prompt_append` 字段

  **Before**:
  ```jsonc
  "visual-engineering": {
    "model": "anthropic/claude-opus-4-5-20251101",
    "prompt_append": "# 移动端响应式 (必须)\n\n..."
  }
  ```

  **After**:
  ```jsonc
  "visual-engineering": {
    "model": "anthropic/claude-opus-4-5-20251101"
  }
  ```

  **References**:
  - `oh-my-opencode.jsonc` - 当前配置文件

  **Acceptance Criteria**:
  - [x] `grep -q "prompt_append" oh-my-opencode.jsonc` 返回失败（不存在）
  - [x] JSON 语法正确

  **Commit**: NO (与下一个任务一起提交)

---

- [x] 4. 删除 AGENTS.md

  **What to do**:
  ```bash
  rm AGENTS.md
  ```

  **Acceptance Criteria**:
  - [x] `ls AGENTS.md` 返回文件不存在

  **Commit**: YES
  - Message: `chore: migrate prompt injection to opencode instructions`
  - Files: `docs/vessel-rules.md`, `opencode.jsonc`, `oh-my-opencode.jsonc`, `AGENTS.md`

---

- [x] 5. 重新构建 Docker 镜像并验证

  **What to do**:
  ```bash
  docker stop vessel-dev && docker rm vessel-dev
  docker build -t localhost:5001/vessel:latest .
  docker run -d --name vessel-dev -p 3300:3300 -p 4096:4096 -p 5173:5173 localhost:5001/vessel:latest
  docker push localhost:5001/vessel:latest
  ```

  **Acceptance Criteria**:
  - [x] `docker exec vessel-dev cat /root/.config/opencode/opencode.json | grep instructions` 显示配置
  - [x] `docker exec vessel-dev cat /workspace/docs/vessel-rules.md` 显示内容
  - [x] `curl http://localhost:3300/health` 返回 healthy
  - [x] `curl http://localhost:4096/global/health` 返回 healthy

  **Commit**: NO

---

## Success Criteria

### Verification Commands
```bash
# 验证配置文件
docker exec vessel-dev cat /root/.config/opencode/opencode.json.qianwen | grep -A2 instructions

# 验证规则文件
docker exec vessel-dev cat /workspace/docs/vessel-rules.md

# 验证服务健康
curl http://localhost:3300/health
curl http://localhost:4096/global/health
```

### Final Checklist
- [x] instructions 配置包含两个文件
- [x] vessel-rules.md 内容正确
- [x] prompt_append 已移除
- [x] AGENTS.md 已删除
- [x] 所有服务正常运行
