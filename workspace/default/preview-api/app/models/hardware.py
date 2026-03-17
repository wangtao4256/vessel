from sqlalchemy import Column, Integer, String, Text, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class HardwareConfig(Base):
    __tablename__ = "hardware_configs"
    
    id = Column(Integer, primary_key=True, index=True)
    serial_number = Column(String(50))
    server_model = Column(String(100))
    os = Column(String(100))
    cpu = Column(String(100))
    memory = Column(String(100))
    system_disk = Column(String(100))
    system_disk_fs_type = Column(String(50))
    system_disk_partition = Column(Text)
    data_disk = Column(String(100))
    data_disk_fs_type = Column(String(50))
    data_disk_partition = Column(Text)
    network = Column(String(50))
    product = Column(Text)
    remark = Column(Text)
    config_level = Column(String(20))
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

class ProductConfigRelation(Base):
    __tablename__ = "product_config_relations"
    
    id = Column(Integer, primary_key=True, index=True)
    hardware_config_id = Column(Integer, ForeignKey("hardware_configs.id", ondelete="CASCADE"), nullable=False)
    machine_count = Column(Integer, nullable=False, default=1)
    remark = Column(Text)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
