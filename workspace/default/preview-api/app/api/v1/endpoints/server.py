from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.server import Server, Database as DatabaseModel

router = APIRouter()


@router.get("/servers/stats")
async def get_server_stats(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Server.environment, func.count(Server.id).label("count")).group_by(
            Server.environment
        )
    )
    results = result.all()

    stats = {env: count for env, count in results}
    stats["total"] = sum(stats.values())
    return {"code": 0, "data": stats}


@router.get("/servers")
async def get_servers(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Server))
    servers = result.scalars().all()

    grouped = {}
    for server in servers:
        if server.environment not in grouped:
            grouped[server.environment] = []
        grouped[server.environment].append(
            {
                "id": server.id,
                "owner": server.owner,
                "project": server.project,
                "usage": server.usage,
                "ip": server.ip,
                "config": server.config,
            }
        )

    return {"code": 0, "data": grouped}


@router.get("/databases/stats")
async def get_database_stats(db: AsyncSession = Depends(get_db)):
    total_result = await db.execute(select(func.count(DatabaseModel.id)))
    total = total_result.scalar()

    result = await db.execute(
        select(
            DatabaseModel.name, func.count(DatabaseModel.id).label("count")
        ).group_by(DatabaseModel.name)
    )
    results = result.all()

    db_types = {name: count for name, count in results}
    return {"code": 0, "data": {"total": total, "types": db_types}}


@router.get("/databases")
async def get_databases(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(DatabaseModel))
    databases = result.scalars().all()

    data = [
        {
            "id": db.id,
            "name": db.name,
            "version": db.version,
            "platform": db.platform,
            "ip": db.ip,
            "port": db.port,
            "user": db.user,
            "password": db.password,
        }
        for db in databases
    ]

    return {"code": 0, "data": data}
