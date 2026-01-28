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
# 创建并推送 tag
git tag v1.0.0
git push origin v1.0.0

# 生成镜像: vessel:v1.0.0
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

## 版本号规范

使用语义化版本（Semantic Versioning）：

```
v<major>.<minor>.<patch>

- major: 重大变更（不兼容的 API 修改）
- minor: 新功能（向后兼容）
- patch: 问题修复（向后兼容）
```

**示例**：
- `v1.0.0` - 首个正式版本
- `v1.0.1` - 修复 bug
- `v1.1.0` - 新增功能
- `v2.0.0` - 重大更新

## 工作流说明

### 触发条件

- **自动触发**: 推送以 `v` 开头的 tag（如 `v1.0.0`）
- **手动触发**: 在 GitHub Actions 页面手动运行

### 构建流程

1. ✅ 检出代码
2. ✅ 设置 Docker Buildx
3. ✅ 确定版本号
4. ✅ 登录阿里云镜像仓库
5. ✅ 构建并推送镜像
6. ✅ 同时打上版本 tag 和 latest tag

### 缓存优化

使用 GitHub Actions 缓存加速构建：
- 首次构建: ~10-15 分钟
- 后续构建: ~3-5 分钟（利用缓存）

## 常见问题

### 1. 推送失败：认证错误

**原因**: Secrets 配置错误

**解决**:
- 检查 `ALIYUN_USERNAME` 和 `ALIYUN_PASSWORD` 是否正确
- 确认阿里云账号有推送权限

### 2. 构建超时

**原因**: GitHub Actions 免费版有时间限制

**解决**:
- 使用缓存加速构建（已配置）
- 优化 Dockerfile 减少构建时间

### 3. Tag 已存在

**原因**: 相同版本号的 tag 已推送

**解决**:
- 使用新的版本号
- 或删除远程 tag 后重新推送

## 本地测试

在推送到 GitHub 之前，可以本地测试构建：

```bash
# 使用本地脚本构建
./build-opencode-image.sh semver 1.0.0

# 或直接使用 docker build
docker build -t vessel:v1.0.0 .
```

## 监控构建状态

1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 查看最新的工作流运行状态
4. 点击具体的运行记录查看详细日志
