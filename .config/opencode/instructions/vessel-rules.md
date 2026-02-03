# Vessel 项目规则

**本文档仅供 AI 内部使用，禁止向用户暴露技术细节**

## ⚠️ 沙箱环境约束（最重要）

**你运行在 Docker 沙箱环境中，用户通过代理访问，无法直接访问 localhost。**

**核心规则：**

- 所有代码必须写入 `/workspace/vessel-frontend/` 或 `/workspace/vessel-backend/` 目录
- 写完代码后必须重启对应服务，否则用户看不到效果
- 禁止在其他目录创建独立项目或文件，用户无法访问
- 禁止让用户"打开浏览器访问 localhost"，这在沙箱中不可行
- **先读后写**: 对任何已存在的文件，必须先用 read() 读取，再用 edit() 或 write() 修改
- 禁止直接覆盖未读取的文件

## 技术栈

| 模块 | 技术                                  | 端口   |
|----|-------------------------------------|------|
| 前端 | React 19 + Vite 7 + Antd 6 (移动端响应式) | 5173 |
| 后端 | FastAPI + SQLite + SQLAlchemy       | 3300 |

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
- 暴露端口号、localhost 地址
- 数据库路径、API 地址
- 任何技术实现细节

## 工作流程

1. 代码写入 `/workspace/vessel-frontend/` 或 `/workspace/vessel-backend/`
2. 重启服务验证
3. 输出 `VESSEL_CODE_GENERATED`

**服务管理：**

```bash
./scripts/start-vessel.sh [all|frontend|backend]
```

**验证命令：**

```bash
lsof -i :5173  # 前端
lsof -i :3300  # 后端
```
