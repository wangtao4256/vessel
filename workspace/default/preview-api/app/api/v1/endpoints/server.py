from fastapi import APIRouter

router = APIRouter()

# 服务器数据
SERVERS = {
    "线上演示环境": [
        {
            "id": 1,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "HDP集群",
            "ip": "172.24.12.82",
            "config": "T7",
        },
        {
            "id": 2,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "HDP集群",
            "ip": "172.24.12.84",
            "config": "T7",
        },
        {
            "id": 3,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "HDP集群",
            "ip": "172.24.12.85",
            "config": "T7",
        },
        {
            "id": 4,
            "owner": "陈先帅",
            "project": "RD24S02002",
            "usage": "演示环境bdos8.0",
            "ip": "172.16.12.166",
            "config": "T7",
        },
        {
            "id": 5,
            "owner": "陈先帅",
            "project": "RD24S02002",
            "usage": "演示环境bdos8.0",
            "ip": "172.16.12.167",
            "config": "T7",
        },
        {
            "id": 6,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "演示环境机器学习",
            "ip": "172.24.12.86",
            "config": "T7",
        },
        {
            "id": 7,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "演示环境机器学习",
            "ip": "172.24.12.87",
            "config": "T7",
        },
        {
            "id": 8,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "演示环境bdos mysql机器",
            "ip": "172.16.12.90",
            "config": "T9",
        },
        {
            "id": 9,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "演示环境api5.2",
            "ip": "172.24.12.91",
            "config": "T7",
        },
        {
            "id": 10,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "演示环境api5.2",
            "ip": "172.24.12.92",
            "config": "T7",
        },
    ],
    "开发环境": [
        {
            "id": 11,
            "owner": "姜楠",
            "project": "RD24S02002",
            "usage": "产品管理系统",
            "ip": "172.24.3.128",
            "config": "T3",
        },
        {
            "id": 12,
            "owner": "姜楠",
            "project": "RD24S02002",
            "usage": "研发内部管理工具",
            "ip": "172.24.4.210",
            "config": "T3",
        },
        {
            "id": 13,
            "owner": "沙红振",
            "project": "RD24S02002",
            "usage": "api开发环境",
            "ip": "172.24.5.192",
            "config": "T3",
        },
        {
            "id": 14,
            "owner": "沙红振",
            "project": "RD24S02002",
            "usage": "api开发环境",
            "ip": "172.24.5.193",
            "config": "T3",
        },
        {
            "id": 15,
            "owner": "沙红振",
            "project": "RD24S02002",
            "usage": "api开发环境",
            "ip": "172.24.5.194",
            "config": "T3",
        },
    ],
    "运维环境": [
        {
            "id": 16,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "产品发布包Installer所在",
            "ip": "172.26.1.73",
            "config": "物理机",
        },
        {
            "id": 17,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "运维使用(arm环境)",
            "ip": "10.0.32.216",
            "config": "物理机",
        },
        {
            "id": 18,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "installer镜像打包仓库",
            "ip": "172.24.3.131",
            "config": "T3",
        },
        {
            "id": 19,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "容器开发公用编译提交环境",
            "ip": "172.24.5.245",
            "config": "T3",
        },
        {
            "id": 20,
            "owner": "韩亚敏",
            "project": "RD24S02002",
            "usage": "开发私有仓库地址",
            "ip": "172.24.5.108",
            "config": "T3",
        },
    ],
    "GPU环境": [
        {
            "id": 21,
            "owner": "研发",
            "project": "RD24S02002",
            "usage": "两个4090卡",
            "ip": "172.18.2.23",
            "config": "GPU",
        },
        {
            "id": 22,
            "owner": "研发",
            "project": "RD24S02002",
            "usage": "4张A100 80G和4张4090 48G的卡",
            "ip": "172.18.2.26",
            "config": "GPU",
        },
    ],
}

# 数据库数据
DATABASES = [
    {
        "id": 1,
        "name": "华为FusionInsight HD",
        "version": "6.5.1",
        "platform": "x86",
        "ip": "172.24.3.180",
        "port": "28443",
        "user": "admin",
        "password": "Huawei@12345",
    },
    {
        "id": 2,
        "name": "MariaDB",
        "version": "10.5.10",
        "platform": "x86",
        "ip": "172.24.5.245",
        "port": "3306",
        "user": "root",
        "password": "root",
    },
    {
        "id": 3,
        "name": "MySQL8",
        "version": "8.0.22",
        "platform": "x86",
        "ip": "172.16.4.80",
        "port": "33060",
        "user": "root",
        "password": "123456",
    },
    {
        "id": 4,
        "name": "GreenPlum",
        "version": "6.12.0",
        "platform": "x86",
        "ip": "172.26.1.73",
        "port": "5433",
        "user": "gpadmin",
        "password": "gpadmin",
    },
    {
        "id": 5,
        "name": "DB2",
        "version": "11.5.7.0",
        "platform": "x86",
        "ip": "172.26.1.73",
        "port": "50001",
        "user": "db2inst1",
        "password": "12345678",
    },
    {
        "id": 6,
        "name": "达梦",
        "version": "V8",
        "platform": "x86",
        "ip": "172.26.1.73",
        "port": "5236",
        "user": "SYSDBA",
        "password": "SYSDBA",
    },
    {
        "id": 7,
        "name": "达梦",
        "version": "V8",
        "platform": "x86",
        "ip": "172.16.4.80",
        "port": "5236",
        "user": "SYSDBA",
        "password": "SYSDBA",
    },
    {
        "id": 8,
        "name": "神通",
        "version": "ShenTong7.0.8",
        "platform": "x86",
        "ip": "172.16.4.80",
        "port": "2003",
        "user": "SYSDBA",
        "password": "szoscar55",
    },
    {
        "id": 9,
        "name": "金仓",
        "version": "V008R006C007B0024",
        "platform": "x86",
        "ip": "172.24.3.131",
        "port": "54321",
        "user": "system",
        "password": "123456789",
    },
    {
        "id": 10,
        "name": "金仓",
        "version": "V008R006C007B0024",
        "platform": "x86",
        "ip": "172.24.5.108",
        "port": "54321",
        "user": "system",
        "password": "admin123456",
    },
    {
        "id": 11,
        "name": "优炫",
        "version": "2.0.4.10",
        "platform": "x86",
        "ip": "172.16.4.80",
        "port": "5432",
        "user": "uxdb",
        "password": "uxdb",
    },
    {
        "id": 12,
        "name": "MongoDB",
        "version": "V4.2.3",
        "platform": "x86docker",
        "ip": "172.24.5.245",
        "port": "27017",
        "user": "root",
        "password": "123456",
    },
    {
        "id": 13,
        "name": "Oracle",
        "version": "11gR2",
        "platform": "x86docker",
        "ip": "172.24.5.245",
        "port": "1521",
        "user": "system",
        "password": "123456",
    },
    {
        "id": 14,
        "name": "Oracle",
        "version": "12c",
        "platform": "x86docker",
        "ip": "172.24.5.245",
        "port": "1523",
        "user": "sys",
        "password": "guns123456",
    },
    {
        "id": 15,
        "name": "MSSQLServer",
        "version": "2019",
        "platform": "x86docker",
        "ip": "172.24.5.245",
        "port": "1433",
        "user": "SA",
        "password": "MyPassWord123",
    },
    {
        "id": 16,
        "name": "PostgreSQL",
        "version": "12.3",
        "platform": "x86docker",
        "ip": "172.26.1.73",
        "port": "54321",
        "user": "postgres",
        "password": "postgres",
    },
]


@router.get("/servers/stats")
async def get_server_stats():
    """获取服务器统计信息"""
    stats = {env: len(servers) for env, servers in SERVERS.items()}
    stats["total"] = sum(stats.values())
    return {"code": 0, "data": stats}


@router.get("/servers")
async def get_servers():
    """获取所有服务器信息"""
    return {"code": 0, "data": SERVERS}


@router.get("/databases/stats")
async def get_database_stats():
    """获取数据库统计信息"""
    db_types = {}
    for db in DATABASES:
        name = db["name"]
        db_types[name] = db_types.get(name, 0) + 1
    return {"code": 0, "data": {"total": len(DATABASES), "types": db_types}}


@router.get("/databases")
async def get_databases():
    """获取所有数据库信息"""
    return {"code": 0, "data": DATABASES}
