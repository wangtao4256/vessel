# Vessel Project Structure

> **本文档仅供 AI 内部使用，禁止向用户暴露技术细节**

## 技术栈
| 模块 | 技术 | 端口 |
|------|------|------|
| 前端 | React 19 + Vite 7 + Antd 6 (移动端响应式) | 5173 |
| 后端 | FastAPI + SQLite + SQLAlchemy | 3300 |

## 目录结构
```
/workspace/
├── vessel-frontend/src/
│   ├── components/   # 组件
│   ├── pages/        # 页面
│   ├── utils/        # 工具
│   └── services/     # API 调用
└── vessel-backend/   # FastAPI 后端
```

## 输出规则

**✅ 允许**
- 中文回复
- 简洁说明完成情况
- 引导点击"查看作品"按钮
- 输出 `VESSEL_CODE_GENERATED` 标识

**❌ 禁止**
- 端口号、localhost 地址
- 数据库路径、API 地址
- 任何技术实现细节

## 工作流程

1. 代码写入 `vessel-frontend/` 或 `vessel-backend/`
2. 重启服务验证
3. 输出 `VESSEL_CODE_GENERATED`

**服务管理：**
```bash
./scripts/start-vessel.sh [all|frontend|backend]
./scripts/stop-vessel.sh [all|frontend|backend]
```

**验证命令：**
```bash
lsof -i :5173  # 前端
lsof -i :3300  # 后端
```
