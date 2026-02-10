from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    app_name: str = "vessel-backend"
    app_version: str = "1.0.0"
    debug: bool = False
    host: str = "0.0.0.0"
    port: int = 3300

    database_url: str = "sqlite+aiosqlite:///./app/vessel.db"

    log_level: str = "INFO"

    acr_registry: str = "ziwuxian-registry.cn-beijing.cr.aliyuncs.com"
    acr_namespace: str = "ai-coding"
    acr_image_name: str = "vessel-preview"
    acr_username: str = ""
    acr_password_encrypted: str = ""

    class Config:
        env_file = ".env"
        case_sensitive = False

    def get_acr_password(self) -> str:
        if not self.acr_password_encrypted:
            return ""
        from app.utils.crypto import decrypt

        return decrypt(self.acr_password_encrypted)


@lru_cache()
def get_settings() -> Settings:
    return Settings()
