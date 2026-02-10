import os
from cryptography.fernet import Fernet

SECRET_KEY = os.getenv("SECRET_KEY", "")


def decrypt(ciphertext: str) -> str:
    if not SECRET_KEY:
        raise ValueError("SECRET_KEY not set")
    f = Fernet(SECRET_KEY.encode())
    return f.decrypt(ciphertext.encode()).decode()
