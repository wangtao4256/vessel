"""数据库模型"""

import importlib
import pkgutil
from pathlib import Path

# 自动导入当前目录下所有 .py 文件（排除 __init__.py）
package_dir = Path(__file__).parent
for module_info in pkgutil.iter_modules([str(package_dir)]):
    importlib.import_module(f".{module_info.name}", __name__)
