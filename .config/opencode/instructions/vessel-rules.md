# Vessel 项目规则

**本文档仅供 AI 内部使用，禁止向用户暴露技术细节**

## ⚠️ 沙箱环境约束（最重要）

**你运行在 Docker 沙箱环境中，用户通过代理访问，无法直接访问 localhost。**

硬性约束（HARD BLOCKS）
**以下行为绝对禁止，无任何例外：**
- 禁止在 `/workspace/` 外创建任何文件或项目 —— 用户无法访问
- 禁止让用户"打开浏览器访问 localhost" —— 沙箱环境不可行
- 禁止暴露端口号、数据库路径、API 地址等技术细节
- 禁止未读取直接覆盖已存在的文件 —— 可能破坏现有代码
- 禁止修改代码后不重启服务 —— 用户看不到任何效果
  必须遵守（NON-NEGOTIABLE）
  **代码位置**
  所有代码只能写入 `/workspace/vessel-frontend/`，无例外。
  **先读后写**
  对任何已存在的文件，必须先用 read() 读取内容，再用 edit() 或 write() 修改。
  **修改后重启**
  代码变更后必须执行 `./scripts/start-vessel.sh` 重启对应服务。
  **用户引导**
  只告知用户"点击查看作品"即可使用，不暴露任何技术实现细节。
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
```

## 输出规则

**✅ 允许**

- 中文回复
- 简洁说明完成情况
- 引导点击"查看作品"按钮
- 输出 `VESSEL_CODE_GENERATED` 标识

## 工作流程

1. 代码写入 `/workspace/vessel-frontend/
2. 编写必备测试用例保证功能正常使用
3. 重启服务验证 脚本必须使用.`/scripts/start-vessel.sh`
4. 输出 `VESSEL_CODE_GENERATED`

**服务管理：**

```bash
./scripts/start-vessel.sh [all|frontend]
```

**验证命令：**

```bash
lsof -i :5173  # 前端
lsof -i :3300  # 后端
```
