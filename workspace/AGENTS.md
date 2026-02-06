# Vessel 项目指南

> 本文档帮助 AI 快速了解项目结构，减少探索时间

## 项目概述

这是一个前端 Web 应用脚手架，运行在 Docker 沙箱环境中。

## 目录结构

```
/workspace/
├── vessel-frontend/     # React 前端
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

## 服务管理

```bash
# 启动服务（会自动先停止已有服务）
./scripts/start-vessel.sh
```

## 开发规范

- 组件放 `components/`，页面放 `pages/`
- 使用 Ant Design 组件，支持移动端响应式
