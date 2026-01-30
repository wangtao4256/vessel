# Learnings - Vessel Global Prompt Injection

## 2026-01-30

### OpenCode instructions 配置

- OpenCode 原生支持 `instructions` 字段，可以直接注入 md 文件
- 配置格式：`"instructions": ["path/to/file.md"]`
- 比 AGENTS.md 和 prompt_append 更稳定可靠

### 注意事项

- Dockerfile 中如果有 COPY 指令引用被删除的文件，构建会失败
- 删除 AGENTS.md 后需要同步更新 Dockerfile
