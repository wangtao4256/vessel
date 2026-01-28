# Vessel Project Structure Template

## 项目概述
Vessel 是一个前后端分离的完整应用系统：
- **前端项目**: `vessel-frontend` - React + Vite + Antd 技术栈
- **后端项目**: `vessel-backend` - Python FastAPI 项目

## 运行环境说明（重要）

**本项目运行在 Docker 沙箱环境中**：
- 用户**无法直接访问** `localhost:5173` 或 `localhost:3300`
- 前端界面通过**代理转发**的方式提供给用户访问
- 当 AI 完成代码生成后，前端会自动识别 `VESSEL_CODE_GENERATED` 标识
- 前端会展示**"查看作品"按钮**，用户点击后可以访问生成的应用

**AI 输出规则（强制）**：
- ✅ **必须**：引导用户点击"查看作品"按钮
- ❌ **禁止**：提示用户访问 `localhost:5173` 或任何本地地址
- ❌ **禁止**：提示用户在浏览器中打开本地链接
- ✅ **正确示例**：「代码已生成完成！请点击上方的"查看作品"按钮预览效果。」
- ❌ **错误示例**：「请访问 http://localhost:5173 查看效果」

## 前端项目结构 (vessel-frontend)

### 技术栈
- **框架**: React 19.2.0
- **构建工具**: Vite 7.2.4
- **UI组件库**: Ant Design 6.2.1
- **语言**: JavaScript (JSX)
- **样式**: CSS + Ant Design

### 目录结构
```
vessel-frontend/
├── public/              # 静态资源
├── src/                 # 源代码
│   ├── App.jsx         # 根组件
│   ├── main.jsx        # 应用入口
│   ├── App.css         # 根组件样式
│   ├── index.css       # 全局样式
│   └── [其他组件文件]  # 待开发
├── index.html          # HTML模板
├── package.json        # 项目依赖
├── vite.config.js      # Vite配置
└── eslint.config.js    # ESLint配置
```

### 当前状态
- 基础React+Vite环境已搭建完成
- 已集成Ant Design UI组件库
- 包含基础的API调用示例（调用 http://192.168.10.47:3300/api/v1/examples）
- 开发服务器启动命令: `npm run dev`
- 构建命令: `npm run build`

### 开发规范
- 使用函数组件 + React Hooks
- 组件文件使用 .jsx 扩展名
- 样式使用 CSS 模块或内联样式
- API调用使用 fetch API
- 主要是服务微信小程序 代码结构样式要兼容

## 后端项目结构 (vessel-backend)

### 位置
- **Docker 环境路径**: `/workspace/vessel-backend`
- **本地开发路径**: 项目根目录下的 `vessel-backend/`

### 技术栈
- **框架**: Python FastAPI
- **数据库**: SQLite (开发环境)
- **ORM**: SQLAlchemy / 其他 ORM
- **API 版本**: v1 (路径前缀: `/api/v1/`)
- **依赖管理**: pip + requirements.txt
- **虚拟环境**: venv

### API 地址配置
- **Docker 环境**: `http://localhost:3300/api/v1/`
- **开发环境**: `http://192.168.10.47:3300/api/v1/`
- **注意**: 用户无法直接访问这些地址（沙箱环境限制）

## 开发指南

### 前端开发
1. 新组件放置在 `src/components/` 目录下
2. 页面级组件放置在 `src/pages/` 目录下
3. 工具函数放置在 `src/utils/` 目录下
4. API调用封装在 `src/services/` 目录下
5. 使用Ant Design组件构建UI界面


### API通信
- 前端通过fetch API调用后端接口
- 基础API地址: `http://192.168.10.47:3300/api/v1/` (开发环境)
- Docker环境: `http://localhost:3300/api/v1/`
- 建议使用统一的API错误处理和响应格式

### 微信小程序兼容性
- 避免使用浏览器特有的 `window`、`document` 对象
- 样式尽量使用相对单位，考虑小程序的 `rpx` 单位转换
- API 调用需要考虑小程序的网络请求限制
- 组件设计要考虑小程序的渲染机制

### 项目启动

#### 使用统一启动脚本
```bash
# 同时启动前后端（会打开两个新终端窗口）
./start-vessel.sh
# 或
./start-vessel.sh all

# 只启动后端
./start-vessel.sh backend

# 只启动前端
./start-vessel.sh frontend

# 查看帮助
./start-vessel.sh --help
```

#### 手动启动
**后端启动**:
```bash
cd /workspace/vessel-backend
source venv/bin/activate
python run.py
```

**前端启动**:
```bash
cd /workspace/vessel-frontend
npm run dev
```

#### 服务地址（仅供内部使用）
- 后端API: http://localhost:3300
- 前端界面: http://localhost:5173
- **注意**: 这些地址仅在 Docker 容器内部可访问，用户无法直接访问

## 快速上手步骤

### 对于新开发者
1. 阅读本模板了解项目结构
2. 分析后端技术栈和API结构
3. 根据需求在前端添加相应组件
4. 在后端创建对应的API端点
5. 实现前后端数据交互

### 对于AI模型

**提示词判断规则（最高优先级）**
在收到任何用户请求时，必须首先判断是否需要生成代码
**判断流程（强制执行）**：
1. **第一步**：分析用户提示词，判断是否需要生成代码 
2. **第二步**：如果需要生成代码 → 必须写入 vessel-frontend/ 或 vessel-backend/
3. **第三步**：代码写入完成后 → 必须输出代码生成标识（见下方"AI 输出标识规则"）
4. **第四步**：必须调用启动/停止脚本验证

**重要：项目路径规则**
- 所有前端代码必须写入到 `vessel-frontend/` 目录下
- 所有后端代码必须写入到 `vessel-backend/` 目录下
- 不要在其他位置创建代码文件
- **如果判断需要生成代码，绝对不允许在其他位置创建文件**

**工作流程**
1. 读取此模板后，你应该了解vessel-frontend的基础架构
2. 可以根据React+Vite+Antd技术栈进行前端开发
3. 需要进一步分析vessel-backend才能进行后端开发
4. 遵循既定的目录结构和开发规范
5. **完成代码编写后，必须自动启动服务进行验证**

**代码放置规则**
- 前端组件 → `vessel-frontend/src/components/`
- 前端页面 → `vessel-frontend/src/pages/`
- 前端工具 → `vessel-frontend/src/utils/`
- 前端API → `vessel-frontend/src/services/`
- 后端代码 → `vessel-backend/` (根据实际技术栈确定具体路径)

**代码生成响应标识规则（重要 - AI 必须执行）**

当 AI 在 `vessel-frontend/` 或 `vessel-backend/` 目录下生成或修改代码后，**必须在回复的最后**输出以下固定格式的标识块，以便前端解析识别并展示"查看作品"按钮。

**AI 输出标识规则（强制）**：

在完成代码生成后，必须在回复末尾输出以下内容：

```
VESSEL_CODE_GENERATED
```

**触发条件**：
- 在 `vessel-frontend/` 目录下创建、修改或删除任何文件 → 必须输出标识
- 在 `vessel-backend/` 目录下创建、修改或删除任何文件 → 必须输出标识
- **即使只修改一个文件，也必须输出标识**

**用户引导规则（强制）**：
- ✅ **必须说**：「代码已生成完成！请点击上方的"查看作品"按钮预览效果。」
- ✅ **可以说**：「已完成开发，点击"查看作品"按钮即可查看运行效果。」
- ❌ **禁止说**：「请访问 http://localhost:5173 查看效果」
- ❌ **禁止说**：「在浏览器中打开 localhost:5173」
- ❌ **禁止说**：任何包含 localhost、127.0.0.1 等本地地址的访问提示

**原因说明**：
- 项目运行在 Docker 沙箱环境中，用户无法直接访问 localhost
- 前端会识别 `VESSEL_CODE_GENERATED` 标识，自动展示"查看作品"按钮
- 用户通过点击按钮，前端会通过代理转发访问应用


**完成后的验证流程（必须执行）**

**关键原则：端口必须保持不变**
- 前端端口：**5173**（绝对不能改变）
- 后端端口：**3300**（绝对不能改变）
- 重复修改代码时，必须通过脚本重启来保持端口一致

**服务状态判断（代码修改前必须检查）**：
1. **第一步**：检查服务是否已经在运行
   ```bash
   # 检查前端服务（端口5173）
   lsof -i :5173
   
   # 检查后端服务（端口3300）
   lsof -i :3300
   ```

2. **第二步**：根据服务状态和修改内容决定操作

| 场景 | 服务状态 | 修改内容 | 操作流程 |
|------|---------|---------|---------|
| 首次启动 | 未运行 | 任何修改 | 直接启动：`./start-vessel.sh [frontend/backend/all]` |
| 重复修改 | 前端运行中 | 只改前端 | 先停止再启动：`./stop-vessel.sh frontend && ./start-vessel.sh frontend` |
| 重复修改 | 后端运行中 | 只改后端 | 先停止再启动：`./stop-vessel.sh backend && ./start-vessel.sh backend` |
| 重复修改 | 都在运行 | 同时修改 | 先停止再启动：`./stop-vessel.sh all && ./start-vessel.sh all` |
| 重复修改 | 部分运行 | 修改对应部分 | 停止对应服务再启动 |

3. **第三步**：验证服务启动和端口
   - 确认前端服务在端口 5173 启动成功
   - 确认后端服务在端口 3300 启动成功
   - 验证服务进程正常运行

4. **第四步**：输出用户引导信息
   - ✅ **必须说**：「代码已生成完成！您可以查看作品预览效果。」
   - ❌ **禁止说**：「请访问 http://localhost:5173 查看效果」
   - 原因：用户在沙箱环境中无法直接访问 localhost

5. **第五步**：如果有错误，修复后重新执行停止→启动流程

**重要提醒**：
- ⚠️ 每次代码修改后，必须先判断服务是否运行
- ⚠️ 如果服务已运行，必须先停止再启动（不能直接启动）
- ⚠️ 端口冲突会导致启动失败，必须通过脚本管理来避免
- ⚠️ 重复输入提示词修改代码时，务必检查并重启服务
- ⚠️ **禁止提示用户访问 localhost 地址，必须引导用户点击"查看作品"按钮**

**启动脚本说明**
- 启动脚本位置: `/workspace/start-vessel.sh` (Docker) 或 `./start-vessel.sh` (本地)
- 停止脚本位置: `/workspace/stop-vessel.sh` (Docker) 或 `./stop-vessel.sh` (本地)
- 脚本会自动处理依赖安装和环境配置
- 前后端会在独立的终端窗口中启动

