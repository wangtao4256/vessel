#!/usr/bin/env python3
import sys

sys.path.insert(0, "/vessel-api")

from app.utils.crypto import encrypt

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python encrypt_password.py <password>")
        sys.exit(1)

    password = sys.argv[1]
    encrypted = encrypt(password)
    print(f"Encrypted: {encrypted}")
    print(f"\nAdd to .env:")
    print(f"ACR_PASSWORD_ENCRYPTED={encrypted}")
