# Vessel 项目指南

> 本文档帮助 AI 快速了解项目结构，减少探索时间

## 项目概述

这是一个全栈 Web 应用脚手架，运行在 Docker 沙箱环境中。

## 目录结构

```
/workspace/
├── vessel-frontend/     # React 前端
├── vessel-backend/      # FastAPI 后端
└── scripts/             # 服务管理脚本
```

## 前端 (vessel-frontend)

| 项目 | 说明 |
|------|------|
| 框架 | React 19 + Vite 7 |
| UI 库 | Ant Design 6 |
| 语法 | JavaScript (JSX) |
| 端口 | 5173 |
| 入口 | `src/App.jsx` |

### 目录说明

```
vessel-frontend/src/
├── App.jsx          # 应用入口
├── App.css          # 全局样式
├── main.jsx         # React 挂载点
├── components/      # 可复用组件
├── pages/           # 页面组件
├── services/        # API 调用封装
├── utils/           # 工具函数
└── assets/          # 静态资源（图片、字体）
```

### API 调用示例

```jsx
// 使用相对路径，Vite 会代理到后端
const response = await fetch('/api/v1/examples');
```

## 后端 (vessel-backend)

| 项目 | 说明 |
|------|------|
| 框架 | FastAPI |
| 数据库 | SQLite + SQLAlchemy (异步) |
| 端口 | 3300 |
| 入口 | `app/main.py` |

### 目录说明

```
vessel-backend/app/
├── main.py          # FastAPI 应用入口
├── config.py        # 配置管理
├── database.py      # 数据库连接
├── models/          # SQLAlchemy 模型
├── schemas/         # Pydantic 模型
├── api/v1/          # API 路由
│   └── endpoints/   # 具体端点
├── services/        # 业务逻辑
└── utils/           # 工具函数
```

### 添加新 API 步骤

1. `models/` 创建数据库模型
2. `schemas/` 创建 Pydantic 模型
3. `api/v1/endpoints/` 创建路由
4. `api/v1/__init__.py` 注册路由

### 现有 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/health` | 健康检查 |
| GET | `/api/v1/examples` | 示例列表 |
| POST | `/api/v1/examples` | 创建示例 |
| GET | `/api/v1/examples/{id}` | 获取示例 |
| PUT | `/api/v1/examples/{id}` | 更新示例 |
| DELETE | `/api/v1/examples/{id}` | 删除示例 |

## 服务管理

```bash
# 启动服务
./scripts/start-vessel.sh all       # 启动全部
./scripts/start-vessel.sh frontend  # 仅前端
./scripts/start-vessel.sh backend   # 仅后端

# 停止服务
./scripts/stop-vessel.sh all
./scripts/stop-vessel.sh frontend
./scripts/stop-vessel.sh backend
```

## 开发规范

### 前端

- 组件放 `components/`，页面放 `pages/`
- API 调用使用相对路径 `/api/v1/...`
- 使用 Ant Design 组件，支持移动端响应式

### 后端

- 遵循 FastAPI 最佳实践
- 使用 async/await 异步操作
- 数据验证使用 Pydantic
