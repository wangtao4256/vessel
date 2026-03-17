from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from typing import List
from app.database import get_db
from app.models.hardware import HardwareConfig, ProductConfigRelation
from app.schemas.hardware import (
    HardwareConfigCreate, HardwareConfigResponse,
    ProductConfigRelationCreate, ProductConfigRelationResponse
)

router = APIRouter()

@router.get("/configs", response_model=List[HardwareConfigResponse])
async def get_hardware_configs(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HardwareConfig))
    return result.scalars().all()

@router.post("/configs", response_model=HardwareConfigResponse)
async def create_hardware_config(config: HardwareConfigCreate, db: AsyncSession = Depends(get_db)):
    db_config = HardwareConfig(**config.dict())
    db.add(db_config)
    await db.commit()
    await db.refresh(db_config)
    return db_config

@router.put("/configs/{config_id}", response_model=HardwareConfigResponse)
async def update_hardware_config(config_id: int, config: HardwareConfigCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HardwareConfig).where(HardwareConfig.id == config_id))
    db_config = result.scalar_one_or_none()
    if not db_config:
        raise HTTPException(status_code=404, detail="配置不存在")
    for key, value in config.dict(exclude_unset=True).items():
        setattr(db_config, key, value)
    await db.commit()
    await db.refresh(db_config)
    return db_config

@router.delete("/configs/{config_id}")
async def delete_hardware_config(config_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(HardwareConfig).where(HardwareConfig.id == config_id))
    db_config = result.scalar_one_or_none()
    if not db_config:
        raise HTTPException(status_code=404, detail="配置不存在")
    await db.execute(delete(HardwareConfig).where(HardwareConfig.id == config_id))
    await db.commit()
    return {"message": "删除成功"}

@router.get("/relations", response_model=List[ProductConfigRelationResponse])
async def get_product_relations(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ProductConfigRelation))
    return result.scalars().all()

@router.post("/relations", response_model=ProductConfigRelationResponse)
async def create_product_relation(relation: ProductConfigRelationCreate, db: AsyncSession = Depends(get_db)):
    db_relation = ProductConfigRelation(**relation.dict())
    db.add(db_relation)
    await db.commit()
    await db.refresh(db_relation)
    return db_relation

@router.delete("/relations/{relation_id}")
async def delete_product_relation(relation_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ProductConfigRelation).where(ProductConfigRelation.id == relation_id))
    db_relation = result.scalar_one_or_none()
    if not db_relation:
        raise HTTPException(status_code=404, detail="关系不存在")
    await db.execute(delete(ProductConfigRelation).where(ProductConfigRelation.id == relation_id))
    await db.commit()
    return {"message": "删除成功"}

@router.get("/relations/with-configs")
async def get_relations_with_configs(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ProductConfigRelation))
    relations = result.scalars().all()
    
    data = []
    for rel in relations:
        config_result = await db.execute(select(HardwareConfig).where(HardwareConfig.id == rel.hardware_config_id))
        config = config_result.scalar_one_or_none()
        if config:
            data.append({
                "id": rel.id,
                "machine_count": rel.machine_count,
                "remark": rel.remark,
                "config": {
                    "id": config.id,
                    "product": config.product,
                    "config_level": config.config_level,
                    "cpu": config.cpu,
                    "memory": config.memory,
                    "system_disk": config.system_disk,
                    "data_disk": config.data_disk,
                    "network": config.network
                }
            })
    return {"data": data}
