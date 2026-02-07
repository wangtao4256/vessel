# ai应用脚手架


## 项目特性

✅ **Python 3.14** - 支持最新的 Python 版本
✅ **FastAPI 0.128.0** - 现代化的 Python Web 框架
✅ **LiteLLM 1.81.0** - 统一的 LLM API 调用接口
✅ **SQLite** - 轻量级数据库（支持异步）
✅ **SQLAlchemy 2.0** - 异步 ORM
✅ **Pydantic 2.12.5** - 数据验证和序列化
✅ **自动 API 文档** - Swagger UI / ReDoc

## 项目结构

```
.
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI 应用入口
│   ├── config.py            # 配置管理
│   ├── database.py          # 数据库配置
│   ├── models/              # 数据库模型
│   │   ├── __init__.py
│   │   └── example.py
│   ├── schemas/             # Pydantic 模型
│   │   ├── __init__.py
│   │   ├── common.py
│   │   └── example.py
│   ├── api/                 # API 路由
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       └── endpoints/
│   │           ├── __init__.py
│   │           ├── example.py
│   │           └── llm.py
│   ├── services/            # 业务逻辑层
│   │   ├── __init__.py
│   │   └── llm_service.py
│   └── utils/               # 工具类
│       └── __init__.py
├── tests/                   # 测试目录
│   └── __init__.py
├── requirements.txt         # 依赖列表
├── .env.example            # 环境变量示例
├── .gitignore
├── run.py                  # 启动脚本
└── README.md
```

## 快速开始

### 方式一：一键部署（推荐）

使用自动化部署脚本，适用于 Linux/macOS 服务器：

```bash
# 1. 克隆项目（如果还没有）
git clone <your-repo-url>
cd vessel-backend

# 2. 运行一键部署脚本
chmod +x deploy.sh
./deploy.sh
```

脚本会自动完成以下操作：
- ✅ 检查 Python 环境（需要 Python 3.11+）
- ✅ 创建虚拟环境
- ✅ 安装所有依赖
- ✅ 配置环境变量
- ✅ 提供启动选项（开发模式/生产模式）

部署完成后，根据提示选择启动方式即可。

### 方式二：手动安装

#### 1. 安装依赖

```bash
# 创建虚拟环境（推荐使用 Python 3.14）
python3.14 -m venv venv

# 激活虚拟环境
# macOS/Linux:
source venv/bin/activate

# 升级 pip
pip install --upgrade pip

# 安装依赖（Python 3.14 需要使用 --only-binary 参数）
pip install --only-binary :all: -r requirements.txt
```

**注意事项**：
- 本项目支持 Python 3.14，但需要使用 `--only-binary :all:` 参数来安装预编译包
- 如果使用 Python 3.11-3.13，可以直接使用 `pip install -r requirements.txt`
- 如果遇到编译错误，请确保使用了 `--only-binary :all:` 参数

### 2. 配置环境变量

### 3. 启动应用

    # 方式1: 使用启动脚本
python run.py

# 方式2: 使用 uvicorn 命令
uvicorn app.main:app --reload --host 0.0.0.0 --port 3300

### 4. 访问 API 文档

启动成功后，访问以下地址：

- **Swagger UI**: http://localhost:3300/docs
- **ReDoc**: http://localhost:3300/redoc
- **健康检查**: http://localhost:3300/health

## API 接口说明

### 示例管理接口

- `GET /api/v1/examples` - 查询示例列表
- `GET /api/v1/examples/page` - 分页查询示例
- `GET /api/v1/examples/{id}` - 根据ID查询示例
- `POST /api/v1/examples` - 创建示例
- `PUT /api/v1/examples/{id}` - 更新示例
- `DELETE /api/v1/examples/{id}` - 删除示例

### LLM 服务接口

- `POST /api/v1/llm/chat` - 聊天补全（支持多轮对话）
- `POST /api/v1/llm/simple-chat` - 简单聊天（单轮对话）
- `GET /api/v1/llm/models` - 获取支持的模型列表

## 使用示例

### 创建示例数据

```bash
curl -X POST "http://localhost:3300/api/v1/examples" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试标题",
    "content": "测试内容",
    "status": 1
  }'
```

### 调用 LLM 服务

```bash
curl -X POST "http://localhost:3300/api/v1/llm/simple-chat" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "你好，请介绍一下自己",
    "model": "gpt-3.5-turbo"
  }'
```

## LiteLLM 支持的模型

LiteLLM 支持多种 LLM 提供商：

- **OpenAI**: gpt-3.5-turbo, gpt-4, gpt-4-turbo-preview
- **Anthropic**: claude-3-opus, claude-3-sonnet, claude-3-haiku
- **Azure OpenAI**: azure/gpt-4
- **Cohere**: command-nightly
- **更多**: 查看 [LiteLLM 文档](https://docs.litellm.ai/docs/)

## 开发指南

### 添加新的 API 端点

1. 在 `app/models/` 创建数据库模型
2. 在 `app/schemas/` 创建 Pydantic 模型
3. 在 `app/api/v1/endpoints/` 创建路由文件
4. 在 `app/api/v1/__init__.py` 注册路由

### 数据库迁移

项目使用 SQLAlchemy，数据库表会在应用启动时自动创建。

如需更复杂的迁移管理，可以集成 Alembic：

```bash
pip install alembic
alembic init alembic
```

## 测试

```bash
# 运行测试
pytest

# 运行测试并查看覆盖率
pytest --cov=app tests/
```

## 代码格式化

```bash
# 格式化代码
black app/

# 检查代码风格
flake8 app/
```

## 环境变量说明

| 变量名 | 说明 | 默认值                             |
|--------|------|---------------------------------|
| APP_NAME | 应用名称 | FastAPI-LiteLLM-Scaffold        |
| APP_VERSION | 应用版本 | 1.0.0                           |
| DEBUG | 调试模式 | True                            |
| HOST | 监听地址 | 0.0.0.0                         |
| PORT | 监听端口 | 3300                            |
| DATABASE_URL | 数据库连接 | sqlite+aiosqlite:///./vessel.db |
| OPENAI_API_KEY | OpenAI API Key | -                               |
| LOG_LEVEL | 日志级别 | INFO                            |

## 故障排除

### Python 3.14 依赖安装问题

**问题描述**：
使用 Python 3.14 时，安装 `pydantic-core` 等包可能会出现编译错误：
```
Building wheel for pydantic-core (pyproject.toml) ... error
TypeError: ForwardRef._evaluate() missing 1 required keyword-only argument: 'recursive_guard'
```

**解决方案**：
使用 `--only-binary :all:` 参数强制使用预编译包：
```bash
pip install --only-binary :all: -r requirements.txt
```

**原因说明**：
- Python 3.14 是最新版本，部分包的旧版本没有预编译的二进制包
- 从源码编译时，Rust 绑定库（PyO3）可能不完全支持 Python 3.14
- 使用 `--only-binary` 参数可以强制使用预编译包，避免编译问题

**替代方案**：
如果仍然遇到问题，可以使用 Python 3.12 或 3.13：
```bash
# 安装 Python 3.13
brew install python@3.13

# 使用 Python 3.13 创建虚拟环境
python3.13 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 许可证

MIT License
