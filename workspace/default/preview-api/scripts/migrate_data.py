import sys
import asyncio
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy import select, delete
from app.database import engine, Base, AsyncSessionLocal
from app.models.server import Server, Database as DatabaseModel


async def migrate_servers():
    servers_data = {
        "线上演示环境": [
            {
                "owner": "张三",
                "project": "PRJ001",
                "usage": "Web服务",
                "ip": "192.168.1.10",
                "config": "4C8G",
            },
            {
                "owner": "李四",
                "project": "PRJ002",
                "usage": "API网关",
                "ip": "192.168.1.11",
                "config": "8C16G",
            },
        ],
        "线上生产环境": [
            {
                "owner": "王五",
                "project": "PRJ003",
                "usage": "数据库",
                "ip": "192.168.2.10",
                "config": "16C32G",
            },
        ],
    }

    async with AsyncSessionLocal() as session:
        await session.execute(delete(Server))

        for env, server_list in servers_data.items():
            for server in server_list:
                db_server = Server(
                    owner=server["owner"],
                    project=server["project"],
                    usage=server["usage"],
                    ip=server["ip"],
                    config=server["config"],
                    environment=env,
                )
                session.add(db_server)

        await session.commit()
        result = await session.execute(select(Server))
        count = len(result.scalars().all())
        print(f"✅ 已导入 {count} 条服务器数据")


async def migrate_databases():
    databases_data = [
        {
            "name": "华为FusionInsight HD",
            "version": "6.5.1",
            "platform": "x86",
            "ip": "172.24.3.180",
            "port": "28443",
            "user": "admin",
            "password": "Huawei@12345",
        },
        {
            "name": "MariaDB",
            "version": "10.5.10",
            "platform": "x86",
            "ip": "172.24.5.245",
            "port": "3306",
            "user": "root",
            "password": "root",
        },
        {
            "name": "MySQL8",
            "version": "8.0.22",
            "platform": "x86",
            "ip": "172.16.4.80",
            "port": "33060",
            "user": "root",
            "password": "123456",
        },
        {
            "name": "GreenPlum",
            "version": "6.12.0",
            "platform": "x86",
            "ip": "172.26.1.73",
            "port": "5433",
            "user": "gpadmin",
            "password": "gpadmin",
        },
        {
            "name": "DB2",
            "version": "11.5.7.0",
            "platform": "x86",
            "ip": "172.26.1.73",
            "port": "50001",
            "user": "db2inst1",
            "password": "12345678",
        },
        {
            "name": "达梦",
            "version": "V8",
            "platform": "x86",
            "ip": "172.26.1.73",
            "port": "5236",
            "user": "SYSDBA",
            "password": "SYSDBA",
        },
        {
            "name": "达梦",
            "version": "V8",
            "platform": "x86",
            "ip": "172.16.4.80",
            "port": "5236",
            "user": "SYSDBA",
            "password": "SYSDBA",
        },
        {
            "name": "神通",
            "version": "ShenTong7.0.8",
            "platform": "x86",
            "ip": "172.16.4.80",
            "port": "2003",
            "user": "SYSDBA",
            "password": "szoscar55",
        },
        {
            "name": "金仓",
            "version": "V008R006C007B0024",
            "platform": "x86",
            "ip": "172.24.3.131",
            "port": "54321",
            "user": "system",
            "password": "123456789",
        },
        {
            "name": "金仓",
            "version": "V008R006C007B0024",
            "platform": "x86",
            "ip": "172.24.5.108",
            "port": "54321",
            "user": "system",
            "password": "admin123456",
        },
        {
            "name": "优炫",
            "version": "2.0.4.10",
            "platform": "x86",
            "ip": "172.16.4.80",
            "port": "5432",
            "user": "uxdb",
            "password": "uxdb",
        },
        {
            "name": "MongoDB",
            "version": "V4.2.3",
            "platform": "x86docker",
            "ip": "172.24.5.245",
            "port": "27017",
            "user": "root",
            "password": "123456",
        },
        {
            "name": "Oracle",
            "version": "11gR2",
            "platform": "x86docker",
            "ip": "172.24.5.245",
            "port": "1521",
            "user": "system",
            "password": "123456",
        },
        {
            "name": "Oracle",
            "version": "12c",
            "platform": "x86docker",
            "ip": "172.24.5.245",
            "port": "1523",
            "user": "sys",
            "password": "guns123456",
        },
        {
            "name": "MSSQLServer",
            "version": "2019",
            "platform": "x86docker",
            "ip": "172.24.5.245",
            "port": "1433",
            "user": "SA",
            "password": "MyPassWord123",
        },
        {
            "name": "PostgreSQL",
            "version": "12.3",
            "platform": "x86docker",
            "ip": "172.26.1.73",
            "port": "54321",
            "user": "postgres",
            "password": "postgres",
        },
    ]

    async with AsyncSessionLocal() as session:
        await session.execute(delete(DatabaseModel))

        for db_data in databases_data:
            db = DatabaseModel(**db_data)
            session.add(db)

        await session.commit()
        result = await session.execute(select(DatabaseModel))
        count = len(result.scalars().all())
        print(f"✅ 已导入 {count} 条数据库数据")


async def main():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    await migrate_servers()
    await migrate_databases()
    print("✅ 数据迁移完成")


if __name__ == "__main__":
    asyncio.run(main())
