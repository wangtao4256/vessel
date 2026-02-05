### SQLAlchemy 规范

本项目使用 SQLAlchemy 2.0 异步模式。

| 禁止 | 正确 |
|------|------|
| `session.query(Model)` | `select(Model)` |
| `.filter()` | `.where()` |
| `session.commit()` | `await session.commit()` |
| `relationship()` 单向 | 必须双向 `back_populates` |
| `.first()` | `.scalar_one_or_none()` |
| `.all()` | `.scalars().all()` |

### 查询结果处理

```python
result = await session.execute(select(User).where(User.id == 1))
user = result.scalar_one_or_none()  # 单条
users = result.scalars().all()       # 多条
```

### FastAPI 路由规范

| 规则 | 说明 |
|------|------|
| 依赖注入获取 session | `db: AsyncSession = Depends(get_db)` |
| 响应模型必须声明 | `response_model=UserResponse` |
| 路径参数用 Path | `user_id: int = Path(..., gt=0)` |
| 查询参数用 Query | `page: int = Query(1, ge=1)` |

### 错误处理

```python
from fastapi import HTTPException

if not user:
    raise HTTPException(status_code=404, detail="用户不存在")
```

### 禁止事项

- 禁止在路由函数中直接写 SQL 字符串
- 禁止捕获异常后静默忽略（空 except）
- 禁止在循环中执行单条查询（N+1 问题）
