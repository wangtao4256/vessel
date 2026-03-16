import sys
import asyncio
from pathlib import Path
import pandas as pd

sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy import delete
from app.database import AsyncSessionLocal, engine, Base
from app.models.server import Server

EXCEL_PATH = '/Users/wangtao/Desktop/运维文档/服务器信息统计.xlsx'

SHEET_CONFIG = {
    'GPU环境': {'skiprows': 1, 'env': 'GPU环境'},
    '线上演示环境': {'skiprows': 4, 'env': '线上演示环境'},
    '运维环境': {'skiprows': 1, 'env': '运维环境'},
    '开发环境': {'skiprows': 1, 'env': '开发环境'},
    '测试环境': {'skiprows': 1, 'env': '测试环境'}
}

async def import_servers():
    async with AsyncSessionLocal() as session:
        await session.execute(delete(Server))
        await session.commit()
        
        total_count = 0
        
        for sheet_name, config in SHEET_CONFIG.items():
            try:
                df = pd.read_excel(EXCEL_PATH, sheet_name=sheet_name, skiprows=config['skiprows'])
                df = df.dropna(subset=['IP'])
                
                for _, row in df.iterrows():
                    server = Server(
                        owner=str(row.get('负责人', '')).strip() if pd.notna(row.get('负责人')) else '',
                        project=str(row.get('项目编码', '')).strip() if pd.notna(row.get('项目编码')) else '',
                        usage=str(row.get('用途', '')).strip() if pd.notna(row.get('用途')) else '',
                        ip=str(row['IP']).strip(),
                        config=str(row.get('配置', '')).strip() if pd.notna(row.get('配置')) else '',
                        environment=config['env']
                    )
                    session.add(server)
                    total_count += 1
                
                print(f'✅ {sheet_name}: 导入 {len(df)} 条')
            except Exception as e:
                print(f'❌ {sheet_name}: {e}')
        
        await session.commit()
        print(f'\n✅ 总计导入 {total_count} 条服务器数据')

async def main():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await import_servers()

if __name__ == '__main__':
    asyncio.run(main())
