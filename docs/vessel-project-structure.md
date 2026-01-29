# Vessel Project Structure

> **📌 文档说明**  
> 本文档是 AI 的内部操作指南，包含端口、路径等技术配置信息，**仅供 AI 内部使用**。  
> AI 在回复用户时，必须严格遵守"AI 输出规则"章节的约束，**不得向用户暴露技术细节**。

## 项目概述
- **前端**: `vessel-frontend` - React 19 + Vite 7 + Antd 6 (移动端响应式)
- **后端**: `vessel-backend` - Python FastAPI + SQLite
- **环境**: Docker 沙箱，用户通过代理访问，无法直接访问 localhost

## AI 输出规则（强制 - 面向用户的输出约束）

### ✅ 允许的输出
- 使用中文作为主要语言
- 代码生成后：简洁说明完成情况（例如："已完成抽奖功能，请点击下方按钮查看效果"）
- 引导用户通过前端界面的"查看作品"按钮访问
- 输出 `VESSEL_CODE_GENERATED` 标识（触发前端自动展示访问入口）

### ❌ 禁止的输出
- **禁止提示端口号**（如 5173、3300）
- **禁止提示 localhost 地址**（用户在沙箱环境中无法访问）
- **禁止提示数据库文件路径**（如 `/workspace/vessel-backend/vessel.db`）
- **禁止提示 API 接口地址**（如 `http://localhost:3300/api/v1/...`）
- **禁止提示任何技术实现细节**（端口、路径、数据库位置等）


## AI 内部配置（仅供 AI 操作使用，不得输出给用户）

### 前端 (vessel-frontend)
- **技术栈**: React 19 + Vite 7 + Antd 6 + JSX
- **目录**: `src/components/` `src/pages/` `src/utils/` `src/services/`
- **规范**: 函数组件 + Hooks, 移动端响应式布局, fetch API
- **开发端口**: 5173 (仅供 AI 内部验证使用)

### 后端 (vessel-backend)
- **技术栈**: FastAPI + SQLite + SQLAlchemy
- **API 地址**: `http://localhost:3300/api/v1/`
- **服务端口**: 3300 (仅供 AI 内部验证使用)
- **数据库**: SQLite (自动创建在 vessel-backend 目录)

### 启动脚本（AI 内部操作）
```bash
./start-vessel.sh [all|frontend|backend]  # 启动服务
./stop-vessel.sh [all|frontend|backend]   # 停止服务
```

### 端口配置（AI 内部使用）
- 前端开发服务器: 5173
- 后端 API 服务: 3300
- **注意**: 端口固定不变，修改代码后必须重启对应服务

## AI 工作流程（强制执行）

### 判断流程
1. 分析用户提示词，判断是否需要生成代码
2. 需要生成代码 → 必须写入 `vessel-frontend/` 或 `vessel-backend/`
3. 代码写入完成 → 必须输出 `VESSEL_CODE_GENERATED` 标识
4. 必须调用启动/停止脚本验证

### 代码放置规则
- 前端组件 → `vessel-frontend/src/components/`
- 前端页面 → `vessel-frontend/src/pages/`
- 前端工具 → `vessel-frontend/src/utils/`
- 前端API → `vessel-frontend/src/services/`
- 后端代码 → `vessel-backend/` (根据实际技术栈)

### 代码生成标识（强制）
完成代码生成后，必须在回复末尾输出：
```
VESSEL_CODE_GENERATED
```

**触发条件**：在 `vessel-frontend/` 或 `vessel-backend/` 目录下创建、修改或删除任何文件


**原因**: 前端会自动识别 `VESSEL_CODE_GENERATED` 标识并展示访问入口，AI 只需简洁说明完成情况即可
### 服务状态检查（AI 内部命令）
```bash
lsof -i :5173  # 检查前端服务
lsof -i :3300  # 检查后端服务
```

### 操作流程（AI 内部执行）

| 场景 | 操作 |
|------|------|
| 首次启动 | `/workspace/start-vessel.sh [frontend/backend/all]` |
| 服务运行中修改代码 | `/workspace/stop-vessel.sh [target] && /workspace/start-vessel.sh [target]` |

### 验证步骤（AI 内部流程）
1. 检查服务是否运行 (`lsof -i :5173` / `lsof -i :3300`)
2. 根据状态决定操作（首次启动 / 停止后重启）
3. 验证服务启动成功和端口正确
4. **向用户输出**：简洁的完成说明 + 引导点击"查看作品"按钮
5. 如有错误，修复后重新执行停止→启动流程
