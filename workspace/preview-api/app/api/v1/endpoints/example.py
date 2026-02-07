from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List
from app.database import get_db
from app.models.example import ExampleModel
from app.schemas.example import ExampleCreate, ExampleUpdate, ExampleResponse
from app.schemas.common import ResponseModel, PageResponse

router = APIRouter()


@router.get("", response_model=ResponseModel[List[ExampleResponse]])
async def list_examples(
    skip: int = 0,
    limit: int = 10,
    db: AsyncSession = Depends(get_db)
):
    """查询示例列表"""
    result = await db.execute(
        select(ExampleModel).offset(skip).limit(limit)
    )
    examples = result.scalars().all()
    return ResponseModel(data=examples)


@router.get("/page", response_model=ResponseModel[PageResponse[ExampleResponse]])
async def page_examples(
    page: int = 1,
    size: int = 10,
    db: AsyncSession = Depends(get_db)
):
    """分页查询示例"""
    # 查询总数
    count_result = await db.execute(select(func.count(ExampleModel.id)))
    total = count_result.scalar()

    # 查询数据
    result = await db.execute(
        select(ExampleModel).offset((page - 1) * size).limit(size)
    )
    examples = result.scalars().all()

    pages = (total + size - 1) // size

    return ResponseModel(data=PageResponse(
        items=examples,
        total=total,
        page=page,
        size=size,
        pages=pages
    ))


@router.get("/{example_id}", response_model=ResponseModel[ExampleResponse])
async def get_example(
    example_id: int,
    db: AsyncSession = Depends(get_db)
):
    """根据ID查询示例"""
    result = await db.execute(
        select(ExampleModel).where(ExampleModel.id == example_id)
    )
    example = result.scalar_one_or_none()

    if not example:
        raise HTTPException(status_code=404, detail="示例不存在")

    return ResponseModel(data=example)


@router.post("", response_model=ResponseModel[ExampleResponse])
async def create_example(
    example: ExampleCreate,
    db: AsyncSession = Depends(get_db)
):
    """创建示例"""
    db_example = ExampleModel(**example.model_dump())
    db.add(db_example)
    await db.flush()
    await db.refresh(db_example)

    return ResponseModel(data=db_example)


@router.put("/{example_id}", response_model=ResponseModel[ExampleResponse])
async def update_example(
    example_id: int,
    example: ExampleUpdate,
    db: AsyncSession = Depends(get_db)
):
    """更新示例"""
    result = await db.execute(
        select(ExampleModel).where(ExampleModel.id == example_id)
    )
    db_example = result.scalar_one_or_none()

    if not db_example:
        raise HTTPException(status_code=404, detail="示例不存在")

    # 更新字段
    update_data = example.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_example, field, value)

    await db.flush()
    await db.refresh(db_example)

    return ResponseModel(data=db_example)


@router.delete("/{example_id}", response_model=ResponseModel[None])
async def delete_example(
    example_id: int,
    db: AsyncSession = Depends(get_db)
):
    """删除示例"""
    result = await db.execute(
        select(ExampleModel).where(ExampleModel.id == example_id)
    )
    db_example = result.scalar_one_or_none()

    if not db_example:
        raise HTTPException(status_code=404, detail="示例不存在")

    await db.delete(db_example)

    return ResponseModel(message="删除成功")
