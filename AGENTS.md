# Vessel 项目知识库

**Generated:** 2025-01-30
**Branch:** master

## 概述

Vessel 是一个 Docker 沙箱化的全栈 Web 应用脚手架，集成 OpenCode AI 开发环境。用于快速构建 React + FastAPI 应用。

## 结构

```
vessel/
├── workspace/           # 应用代码 (详见 workspace/AGENTS.md)
│   ├── vessel-frontend/ # React 19 + Vite 7 + Antd 6
│   ├── vessel-backend/  # FastAPI + SQLite
│   └── scripts/         # 服务管理脚本
├── skills/              # OpenCode 技能包
│   ├── ui-ux-pro-max/   # UI/UX 设计智能 (SKILL.md)
│   └── vessel-lite-proxy-skill/  # LiteLLM 代理参考
├── .config/opencode/    # OpenCode 配置
├── .github/workflows/   # CI/CD (阿里云镜像推送)
└── Dockerfile           # 多阶段构建镜像
```

## 文档索引

| 文档 | 什么时候读 | 包含内容 |
|------|------------|----------|
| `workspace/AGENTS.md` | 开发前后端功能时、添加 API 时、修改组件时 | 前后端技术栈、目录结构、API 列表、开发规范 |
| `.github/workflows/README.md` | 发布镜像时、配置 CI/CD 时 | GitHub Actions 配置、版本号规范、阿里云推送 |
| `skills/ui-ux-pro-max/SKILL.md` | 设计 UI 组件时、选择配色/字体时 | 50+ 设计风格、97 配色方案、57 字体搭配 |
| `skills/vessel-lite-proxy-skill/SKILL.md` | 集成 LiteLLM 时、调用图像/视频生成 API 时 | 通义万相 API、计费模块、权限管理 |

## 关键约束

### 沙箱环境 (CRITICAL)

- 代码**必须**写入 `/workspace/vessel-frontend/` 或 `/workspace/vessel-backend/`
- 写完代码**必须**重启服务: `./scripts/start-vessel.sh [all|frontend|backend]`
- **禁止**让用户访问 localhost (沙箱内不可行)
- **禁止**向用户暴露端口号、数据库路径等技术细节

### 输出规范

- 完成后输出 `VESSEL_CODE_GENERATED` 标识
- 引导用户点击"查看作品"按钮
- 使用中文回复

## 命令

```bash
# 服务管理（启动时会自动先停止已有服务）
./workspace/scripts/start-vessel.sh all      # 启动全部

# Docker 构建
docker build -t vessel:v1.0.0 .

# 发布 (推送 tag 触发 CI)
git tag v1.0.0 && git push origin v1.0.0
```

## 端口 (内部使用)

| 服务 | 端口 |
|------|------|
| Frontend (Vite) | 5173 |
| Backend (FastAPI) | 3300 |
| OpenCode | 4096 |
