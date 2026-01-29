# Vessel Lite Proxy 项目详细文档

## 项目概述

Vessel Lite Proxy 是基于 LiteLLM 的多模态 AI 代理服务。

**项目位置**：`/Users/wangtao/IdeaProjects/vessel-lite-proxy`

## 完整项目结构

```
vessel-lite-proxy/
├── litellm_proxy_extended.py
├── litellm_config.yaml
├── start-litellm.sh
├── requirements.txt
├── .env
└── app/
    ├── services/
    │   ├── custom_tongyi_handler.py
    │   └── permission_service.py
    ├── billing/
    │   ├── cost_logger.py
    │   ├── litellm_callback.py
    │   └── request_context.py
    ├── middleware/
    │   └── billing_middleware.py
    └── hooks/
        └── permission_checker.py
```

## API 接口详细说明

### 图像生成接口

**端点**：`POST /api/v1/images/generation`

**完整参数**：
- `prompt` (必填): 文本提示词
- `size` (可选): 图片尺寸，默认 "1280*1280"
- `n` (可选): 生成数量，默认 1
- `model` (可选): 模型名称
- `negative_prompt` (可选): 负面提示词
- `prompt_extend` (可选): 提示词扩展
- `watermark` (可选): 水印

### 视频生成接口

**端点**：`POST /api/v1/videos/generation`

**完整参数**：
- `prompt` (必填): 文本提示词
- `img_url` (必填): 起始图片 URL
- `resolution` (可选): 视频分辨率
- `duration` (可选): 视频时长（秒）


