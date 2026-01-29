---
name: vessel-lite-proxy
description: Vessel Lite Proxy 项目知识库。基于 LiteLLM 的多模态 AI 代理服务，提供图像生成（文生图）、视频生成（图生视频）和 LLM 聊天功能。使用场景：(1) 了解 vessel-lite-proxy 项目架构时，(2) 调用图像/视频生成 API 时，(3) 配置 LiteLLM Proxy 时，(4) 集成通义万相多模态能力时。
---

# Vessel Lite Proxy

## Overview

Vessel Lite Proxy 是基于 LiteLLM 的多模态 AI 代理服务，扩展了标准 LiteLLM Proxy，集成通义万相的图像生成和视频生成能力。项目位置：`/Users/wangtao/IdeaProjects/vessel-lite-proxy`

## 核心能力

1. **文生图**：`POST /api/v1/images/generation` - 通义万相图像生成
2. **图生视频**：`POST /api/v1/videos/generation` - 通义万相视频生成
3. **LLM 聊天**：`POST /chat/completions` - OpenAI 兼容接口
4. **统一计费**：自动记录成本到 `cost_records.jsonl`
5. **权限管理**：集成外部权限服务

## 项目结构

```
vessel-lite-proxy/
├── litellm_proxy_extended.py    # 主入口
├── litellm_config.yaml          # LiteLLM 配置
├── start-litellm.sh             # 启动脚本
├── app/
│   ├── services/
│   │   ├── custom_tongyi_handler.py    # 通义万相处理器
│   │   └── permission_service.py
│   ├── billing/                 # 计费模块
│   ├── middleware/              # 中间件
│   └── hooks/                   # 权限检查
└── cost_records.jsonl           # 成本记录
```

## API 接口

### 图像生成

**端点**：`POST /api/v1/images/generation`

**请求示例**：
```json
{
  "prompt": "一只可爱的猫咪",
  "size": "1280*1280",
  "n": 1
}
```
### 视频生成

**端点**：`POST /api/v1/videos/generation`

**请求示例**：
```json
{
  "prompt": "猫咪在草地上奔跑",
  "img_url": "https://example.com/cat.jpg",
  "resolution": "720P",
  "duration": 10
}
```
## 配置

### 环境变量

| 变量名 | 说明 | 必填 |
|--------|------|------|
| DASHSCOPE_API_KEY | 通义万相 API Key | ✅ |
| LITELLM_MASTER_KEY | LiteLLM 主密钥 | ✅ |
### 启动服务

```bash
cd /Users/wangtao/IdeaProjects/vessel-lite-proxy
source venv/bin/activate
./start-litellm.sh
```

访问文档：http://localhost:4000/docs

## 参考文档

详细的 API 参数和项目架构请参考：`references/project_details.md`
