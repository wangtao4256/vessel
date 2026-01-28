# GitHub Actions 自动部署配置

## 概述

本项目使用 GitHub Actions 自动构建 Docker 镜像并推送到阿里云镜像仓库。

## 配置步骤

### 1. 添加 GitHub Secrets

在 GitHub 仓库中配置以下 Secrets：

1. 进入仓库 → `Settings` → `Secrets and variables` → `Actions`
2. 点击 `New repository secret`
3. 添加以下两个 secrets：

| Secret 名称 | 说明 | 获取方式 |
|------------|------|---------|
| `ALIYUN_USERNAME` | 阿里云镜像仓库用户名 | 阿里云控制台 → 容器镜像服务 → 访问凭证 |
| `ALIYUN_PASSWORD` | 阿里云镜像仓库密码 | 阿里云控制台 → 容器镜像服务 → 访问凭证 |

### 2. 触发方式

#### 方式 1: 推送 Git Tag（推荐）

```bash
git tag v1.0.0
git push origin v1.0.0
```

#### 方式 2: 手动触发

1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 选择 `Build and Push to Aliyun` 工作流
4. 点击 `Run workflow`
5. 输入版本号（如 `1.0.0`）
6. 点击 `Run workflow` 按钮

### 3. 生成的镜像

```
ziwuxian-registry.cn-beijing.cr.aliyuncs.com/ai-coding/vessel:v1.0.0
ziwuxian-registry.cn-beijing.cr.aliyuncs.com/ai-coding/vessel:latest
```
