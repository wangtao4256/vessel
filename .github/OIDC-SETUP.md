# 阿里云 ACR OIDC 认证配置指南

## 概述

本项目使用 GitHub Actions OIDC 与阿里云 ACR 企业版进行无密码认证，更安全且无需管理长期凭证。

## 当前配置

### GitHub Actions 工作流

```yaml
permissions:
  id-token: write    # OIDC 令牌写入权限
  contents: write    # Git tag 推送权限

steps:
  - name: Configure Aliyun Credentials
    uses: aliyun/configure-aliyun-credentials-action@v1
    with:
      region-id: cn-beijing

  - name: Login to ACR Enterprise Edition
    uses: aliyun/acr-login@v1
    with:
      login-server: ziwuxian-registry.cn-beijing.cr.aliyuncs.com
      region-id: cn-beijing
      instance-id: ${{ secrets.ACR_INSTANCE_ID }}
```

## 阿里云配置步骤

### 第一步：创建 OIDC 身份提供商

1. 登录阿里云控制台
2. 进入 **RAM 访问控制** → **身份提供商**
3. 点击 **创建身份提供商**
4. 选择 **OIDC**
5. 填写配置：

```
提供商名称: github-actions
提供商 URL: https://token.actions.githubusercontent.com
受众 (Audience): sts.aliyuncs.com
```

6. 点击 **确定**

### 第二步：创建 RAM 角色

1. **RAM 访问控制** → **角色** → **创建角色**
2. 选择 **身份提供商**
3. 选择刚创建的 `github-actions` 提供商
4. 配置信任策略：

```json
{
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithOIDC",
      "Effect": "Allow",
      "Principal": {
        "Federated": [
          "acs:ram::YOUR_ACCOUNT_ID:oidc-provider/github-actions"
        ]
      },
      "Condition": {
        "StringEquals": {
          "oidc:aud": "sts.aliyuncs.com",
          "oidc:sub": "repo:ziwuxian-tech/vessel:ref:refs/heads/master"
        }
      }
    }
  ],
  "Version": "1"
}
```

**注意**：
- 替换 `YOUR_ACCOUNT_ID` 为你的阿里云账号 ID
- `oidc:sub` 限制只有 `vessel` 仓库的 `master` 分支可以使用此角色

5. 角色名称：`github-actions-acr-role`
6. 点击 **确定**

### 第三步：为角色添加权限

1. 找到刚创建的角色 `github-actions-acr-role`
2. 点击 **添加权限**
3. 选择权限策略：`AliyunContainerRegistryFullAccess`
4. 点击 **确定**

### 第四步：获取 ACR 实例 ID

1. 进入 **容器镜像服务 ACR**
2. 选择 **企业版实例**
3. 复制实例 ID（格式：`cri-xxxxxx`）

## GitHub 配置步骤

### 配置 Secrets

进入 GitHub 仓库：**Settings → Secrets and variables → Actions**

添加以下 Secret：

| Secret 名称 | 值 | 说明 |
|------------|---|------|
| `ACR_INSTANCE_ID` | `cri-xxxxxx` | ACR 企业版实例 ID |

## 工作原理

1. GitHub Actions 运行时生成 OIDC Token
2. Token 包含仓库信息（repo、ref、sha 等）
3. 阿里云 STS 验证 Token 的真实性
4. 验证通过后，临时授予 RAM 角色权限
5. 使用临时凭证登录 ACR 并推送镜像

## 优势

✅ **无需管理密码** - 不需要存储长期凭证
✅ **更安全** - 临时凭证自动过期
✅ **细粒度控制** - 可限制特定仓库/分支
✅ **审计友好** - 所有操作可追溯
