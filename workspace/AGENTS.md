# Vessel 项目指南

> 本文档帮助 AI 快速了解项目结构，减少探索时间

## 项目概述

这是一个前端 Web 应用脚手架，运行在 Docker 沙箱环境中。

## 目录结构

```
/workspace/
├── preview-api/         # Python 后端 (FastAPI)
└── scripts/             # 服务管理脚本
```

## 后端 (preview-api)

| 项目 | 说明 |
|------|------|
| 框架 | FastAPI |
| 端口 | 3300 |
| 入口 | `app/main.py` |

### 目录说明

```
preview-api/
├── app/
│   ├── main.py          # 应用入口
│   ├── config.py        # 配置管理
│   ├── database.py      # 数据库连接
│   ├── api/v1/          # API 路由
│   ├── models/          # 数据模型
│   ├── schemas/         # Pydantic schemas
│   ├── services/        # 业务逻辑
│   └── utils/           # 工具函数
├── tests/               # 测试
├── run.py               # 启动脚本
└── requirements.txt     # 依赖
```

## 服务管理

```bash
# 启动服务（会自动先停止已有服务）
./scripts/start-vessel.sh
```

## 开发规范

- API 路由放 `app/api/v1/endpoints/`
- 业务逻辑放 `app/services/`
- 数据模型放 `app/models/`
