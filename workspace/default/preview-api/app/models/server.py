from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.database import Base


class Server(Base):
    __tablename__ = "servers"

    id = Column(Integer, primary_key=True, index=True)
    owner = Column(String(50), nullable=False, comment="负责人")
    project = Column(String(50), nullable=False, comment="项目编码")
    usage = Column(String(200), nullable=False, comment="用途")
    ip = Column(String(50), nullable=False, unique=True, comment="IP地址")
    config = Column(String(50), comment="配置")
    environment = Column(String(50), nullable=False, index=True, comment="环境类型")
    created_at = Column(DateTime, server_default=func.now(), comment="创建时间")
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment="更新时间")


class Database(Base):
    __tablename__ = "databases"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, comment="数据库名称")
    version = Column(String(50), nullable=False, comment="版本")
    platform = Column(String(50), nullable=False, comment="平台")
    ip = Column(String(50), nullable=False, comment="IP地址")
    port = Column(String(10), nullable=False, comment="端口")
    user = Column(String(100), nullable=False, comment="用户名")
    password = Column(String(200), nullable=False, comment="密码")
    created_at = Column(DateTime, server_default=func.now(), comment="创建时间")
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment="更新时间")
