from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class HardwareConfigBase(BaseModel):
    serial_number: Optional[str] = None
    server_model: Optional[str] = None
    os: Optional[str] = None
    cpu: Optional[str] = None
    memory: Optional[str] = None
    system_disk: Optional[str] = None
    system_disk_fs_type: Optional[str] = None
    system_disk_partition: Optional[str] = None
    data_disk: Optional[str] = None
    data_disk_fs_type: Optional[str] = None
    data_disk_partition: Optional[str] = None
    network: Optional[str] = None
    product: Optional[str] = None
    remark: Optional[str] = None
    config_level: Optional[str] = None

class HardwareConfigCreate(HardwareConfigBase):
    pass

class HardwareConfigResponse(HardwareConfigBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class ProductConfigRelationCreate(BaseModel):
    hardware_config_id: int
    machine_count: int = 1
    remark: Optional[str] = None

class ProductConfigRelationResponse(BaseModel):
    id: int
    hardware_config_id: int
    machine_count: int
    remark: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True
