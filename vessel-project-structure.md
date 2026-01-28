# Vessel Project Structure

## 项目概述
- **前端**: `vessel-frontend` - React 19 + Vite 7 + Antd 6 (移动端响应式)
- **后端**: `vessel-backend` - Python FastAPI + SQLite
- **环境**: Docker 沙箱，用户通过代理访问，无法直接访问 localhost

## AI 输出规则（强制）
- ✅ 引导用户点击"查看作品"按钮
- ❌ 禁止提示访问 localhost 地址
- 代码生成后必须输出 `VESSEL_CODE_GENERATED` 标识

## 前端 (vessel-frontend)
**技术栈**: React 19 + Vite 7 + Antd 6 + JSX
**目录**: `src/components/` `src/pages/` `src/utils/` `src/services/`
**规范**: 函数组件 + Hooks, 移动端响应式, fetch API

## 后端 (vessel-backend)
**技术栈**: FastAPI + SQLite + SQLAlchemy
**API**: `http://192.168.10.47:3300/api/v1/` (开发) / `http://localhost:3300/api/v1/` (Docker)

## 启动脚本
```bash
./start-vessel.sh [all|frontend|backend]  # 启动服务
./stop-vessel.sh [all|frontend|backend]   # 停止服务
```
**端口**: 前端 5173, 后端 3300 (固定不变)

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

**用户引导**：
- ✅ 「代码已生成完成！请点击上方的"查看作品"按钮预览效果。」
- ❌ 「请访问 http://localhost:5173 查看效果」
## 验证流程（必须执行）

### 服务状态检查
```bash
lsof -i :5173  # 检查前端
lsof -i :3300  # 检查后端
```

### 操作流程

| 场景 | 操作 |
|------|------|
| 首次启动 | `./start-vessel.sh [frontend/backend/all]` |
| 服务运行中修改代码 | `./stop-vessel.sh [target] && ./start-vessel.sh [target]` |

### 验证步骤
1. 检查服务是否运行 (`lsof -i :5173` / `lsof -i :3300`)
2. 根据状态决定操作（首次启动 / 停止后重启）
3. 验证服务启动成功和端口正确
4. 输出用户引导信息（引导点击"查看作品"按钮）
5. 如有错误，修复后重新执行停止→启动流程

**重要**: 端口固定不变（前端 5173，后端 3300），修改代码后必须重启服务
