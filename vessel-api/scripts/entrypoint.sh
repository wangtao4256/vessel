#!/bin/sh
set -e

find_dir() {
    dir_name=$1
    if [ -d "/workspace/$dir_name" ]; then
        echo "/workspace/$dir_name"
        return
    fi
    found=$(find /workspace -maxdepth 2 -type d -name "$dir_name" 2>/dev/null | head -1)
    if [ -n "$found" ]; then
        echo "$found"
        return
    fi
    echo ""
}

install_backend_deps() {
    cd "$1"
    if [ -f "requirements.txt" ]; then
        echo "Checking backend dependencies..."
        pip install --no-cache-dir -r requirements.txt 2>/dev/null || true
    fi
}

PREVIEW_API_DIR=$(find_dir "preview-api")

echo "=== Vessel Preview Entrypoint ==="
echo "Preview API: ${PREVIEW_API_DIR:-NOT FOUND}"

if [ -n "$PREVIEW_API_DIR" ]; then
    install_backend_deps "$PREVIEW_API_DIR"
    echo "Starting backend on port 3400..."
    cd "$PREVIEW_API_DIR"
    uvicorn app.main:app --host 0.0.0.0 --port 3400
else
    echo "ERROR: preview-api not found"
    exit 1
fi
