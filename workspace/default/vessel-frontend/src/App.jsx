import { useState, useEffect } from 'react'
import Login from './Login'
import './App.css'

function App() {
    const [isLoggedIn, setIsLoggedIn] = useState(false)
    const [activeMenu, setActiveMenu] = useState('dashboard')
    const [serverStats, setServerStats] = useState({})
    const [servers, setServers] = useState([])
    const [databases, setDatabases] = useState([])
    const [groupedServers, setGroupedServers] = useState({})
    const [activeTab, setActiveTab] = useState('servers')
    const [activeEnv, setActiveEnv] = useState('')

    useEffect(() => {
        const token = localStorage.getItem('token')
        setIsLoggedIn(!!token)
        if (token) fetchData()
    }, [])

    const fetchData = async () => {
        try {
            const [statsRes, serversRes, dbRes] = await Promise.all([
                fetch('/api/v1/server/servers/stats'),
                fetch('/api/v1/server/servers'),
                fetch('/api/v1/server/databases')
            ])
            const statsData = await statsRes.json()
            const serversData = await serversRes.json()
            const dbData = await dbRes.json()
            
            setServerStats({ ...statsData.data, online: statsData.data.total - 2, alerts: 23, tickets: 47 })
            setGroupedServers(serversData.data)
            
            const serverList = []
            Object.entries(serversData.data).forEach(([env, list]) => {
                list.forEach(s => serverList.push({ ...s, environment: env, status: 'online', cpu: '45%', memory: '67%' }))
            })
            setServers(serverList.slice(0, 3))
            setDatabases(dbData.data)
            
            if (!activeEnv && Object.keys(serversData.data).length > 0) {
                setActiveEnv(Object.keys(serversData.data)[0])
            }
        } catch (error) {
            console.error('获取数据失败:', error)
        }
    }

    const handleLogout = () => {
        localStorage.removeItem('token')
        setIsLoggedIn(false)
    }

    if (!isLoggedIn) {
        return <Login onLoginSuccess={() => setIsLoggedIn(true)} />
    }

    return (
        <div className="bg-gray-950 text-gray-100 min-h-screen font-sans">
            <aside className="fixed left-0 top-0 h-full w-64 bg-gray-900 border-r border-gray-800 z-50">
                <div className="p-6">
                    <h1 className="text-xl font-bold text-primary">运维管理系统</h1>
                </div>
                <nav className="px-3">
                    {[
                        { key: 'dashboard', label: '监控中心', icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6' },
                        { key: 'assets', label: '资产管理', icon: 'M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01' },
                        { key: 'logs', label: '日志中心', icon: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z' }
                    ].map(item => (
                        <a key={item.key} onClick={() => setActiveMenu(item.key)} className={`flex items-center gap-3 px-4 py-3 rounded-lg mb-1 cursor-pointer transition-colors duration-200 ${activeMenu === item.key ? 'bg-primary/20 text-primary' : 'text-gray-400 hover:bg-gray-800 hover:text-gray-100'}`}>
                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d={item.icon}/></svg>
                            <span>{item.label}</span>
                        </a>
                    ))}
                </nav>
            </aside>

            <main className="ml-64 min-h-screen">
                <header className="bg-gray-900 border-b border-gray-800 sticky top-0 z-40">
                    <div className="flex items-center justify-between px-6 py-4">
                        <h2 className="text-lg font-semibold">{activeMenu === 'dashboard' ? '监控中心' : activeMenu === 'assets' ? '资产管理' : '日志中心'}</h2>
                        <div className="flex items-center gap-4">
                            <button className="relative cursor-pointer transition-colors duration-200 hover:text-primary">
                                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>
                                <span className="absolute -top-1 -right-1 w-2 h-2 bg-cta rounded-full"></span>
                            </button>
                            <div className="flex items-center gap-2 cursor-pointer" onClick={handleLogout}>
                                <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-sm font-semibold">管</div>
                                <span className="text-sm">管理员</span>
                            </div>
                        </div>
                    </div>
                </header>

                {activeMenu === 'dashboard' && (
                    <div className="p-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                            {[
                                { label: '服务器总数', value: serverStats.total, icon: 'M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01', color: 'text-primary', sub: '↑ 12 本月新增', subColor: 'text-green-400', onClick: () => { setActiveMenu('assets'); setActiveTab('servers'); } },
                                { label: '在线率', value: serverStats.total ? `${((serverStats.online / serverStats.total) * 100).toFixed(1)}%` : '0%', icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z', color: 'text-green-400', sub: `${serverStats.online}/${serverStats.total} 在线`, subColor: 'text-green-400' },
                                { label: '告警数量', value: serverStats.alerts, icon: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z', color: 'text-cta', sub: '5 严重 / 18 警告', subColor: 'text-cta', hover: 'hover:border-cta' },
                                { label: '待处理工单', value: serverStats.tickets, icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2', color: 'text-secondary', sub: '12 紧急处理', subColor: 'text-yellow-400' }
                            ].map((stat, i) => (
                                <div key={i} onClick={stat.onClick} className={`bg-gray-900 border border-gray-800 rounded-lg p-6 cursor-pointer transition-all duration-200 ${stat.hover || 'hover:border-primary'}`}>
                                    <div className="flex items-center justify-between mb-2">
                                        <span className="text-gray-400 text-sm">{stat.label}</span>
                                        <svg className={`w-5 h-5 ${stat.color}`} fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d={stat.icon}/></svg>
                                    </div>
                                    <div className="text-3xl font-bold mb-1">{stat.value}</div>
                                    <div className={`text-xs ${stat.subColor}`}>{stat.sub}</div>
                                </div>
                            ))}
                        </div>

                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                            <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
                                <h3 className="text-lg font-semibold mb-4">实时告警</h3>
                                <div className="space-y-3">
                                    {[
                                        { level: '严重', time: '2分钟前', msg: 'prod-web-01 CPU使用率超过90%', color: 'red' },
                                        { level: '警告', time: '15分钟前', msg: 'prod-db-02 磁盘空间不足20%', color: 'yellow' },
                                        { level: '严重', time: '1小时前', msg: 'prod-cache-01 Redis连接数异常', color: 'red' }
                                    ].map((alert, i) => (
                                        <div key={i} className={`flex items-start gap-3 p-3 bg-${alert.color}-500/10 border border-${alert.color}-500/20 rounded-lg cursor-pointer hover:bg-${alert.color}-500/20 transition-colors duration-200`}>
                                            <div className={`w-2 h-2 bg-${alert.color}-500 rounded-full mt-2`}></div>
                                            <div className="flex-1">
                                                <div className="flex items-center justify-between mb-1">
                                                    <span className={`font-medium text-${alert.color}-400`}>{alert.level}</span>
                                                    <span className="text-xs text-gray-400">{alert.time}</span>
                                                </div>
                                                <p className="text-sm">{alert.msg}</p>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
                                <h3 className="text-lg font-semibold mb-4">服务器状态</h3>
                                <div className="space-y-4">
                                    {[
                                        { label: 'CPU平均使用率', value: '45%', width: 45, color: 'bg-primary' },
                                        { label: '内存平均使用率', value: '67%', width: 67, color: 'bg-secondary' },
                                        { label: '磁盘平均使用率', value: '52%', width: 52, color: 'bg-green-500' },
                                        { label: '网络流量', value: '1.2 GB/s', width: 30, color: 'bg-cta' }
                                    ].map((stat, i) => (
                                        <div key={i}>
                                            <div className="flex items-center justify-between mb-2">
                                                <span className="text-sm text-gray-400">{stat.label}</span>
                                                <span className="text-sm font-mono">{stat.value}</span>
                                            </div>
                                            <div className="w-full bg-gray-800 rounded-full h-2">
                                                <div className={`${stat.color} h-2 rounded-full transition-all duration-300`} style={{width: `${stat.width}%`}}></div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>

                        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
                            <div className="flex items-center justify-between mb-4">
                                <h3 className="text-lg font-semibold">服务器列表</h3>
                                <button className="px-4 py-2 bg-primary hover:bg-primary/80 rounded-lg text-sm font-medium cursor-pointer transition-colors duration-200">添加服务器</button>
                            </div>
                            <div className="overflow-x-auto">
                                <table className="w-full">
                                    <thead>
                                        <tr className="border-b border-gray-800">
                                            <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">主机名</th>
                                            <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">IP地址</th>
                                            <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">状态</th>
                                            <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">CPU</th>
                                            <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">内存</th>
                                            <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">操作</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {servers.map(server => (
                                            <tr key={server.id} className="border-b border-gray-800 hover:bg-gray-800/50 cursor-pointer transition-colors duration-200">
                                                <td className="py-3 px-4 font-mono text-sm">{server.project || 'N/A'}</td>
                                                <td className="py-3 px-4 font-mono text-sm text-gray-400">{server.ip}</td>
                                                <td className="py-3 px-4">
                                                    <span className={`px-2 py-1 rounded text-xs ${server.status === 'online' ? 'bg-green-500/20 text-green-400' : 'bg-red-500/20 text-red-400'}`}>
                                                        {server.status === 'online' ? '在线' : '离线'}
                                                    </span>
                                                </td>
                                                <td className="py-3 px-4 font-mono text-sm">{server.cpu}</td>
                                                <td className="py-3 px-4 font-mono text-sm">{server.memory}</td>
                                                <td className="py-3 px-4"><button className="text-primary hover:text-primary/80 text-sm cursor-pointer transition-colors duration-200">详情</button></td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                )}

                {activeMenu === 'assets' && (
                    <div className="p-6">
                        <div className="bg-gray-900 border border-gray-800 rounded-lg mb-6">
                            <div className="border-b border-gray-800">
                                <div className="flex gap-2 px-4">
                                    <button onClick={() => setActiveTab('servers')} className={`px-4 py-3 text-sm font-medium transition-colors duration-200 border-b-2 ${activeTab === 'servers' ? 'border-primary text-primary' : 'border-transparent text-gray-400 hover:text-gray-100'}`}>
                                        服务器管理
                                    </button>
                                    <button onClick={() => setActiveTab('databases')} className={`px-4 py-3 text-sm font-medium transition-colors duration-200 border-b-2 ${activeTab === 'databases' ? 'border-primary text-primary' : 'border-transparent text-gray-400 hover:text-gray-100'}`}>
                                        数据库管理
                                    </button>
                                </div>
                            </div>

                            {activeTab === 'servers' && (
                                <div className="p-6">
                                    <div className="border-b border-gray-800 mb-4">
                                        <div className="flex gap-2">
                                            {Object.keys(groupedServers).map(env => (
                                                <button key={env} onClick={() => setActiveEnv(env)} className={`px-4 py-2 text-sm transition-colors duration-200 border-b-2 ${activeEnv === env ? 'border-secondary text-secondary' : 'border-transparent text-gray-400 hover:text-gray-100'}`}>
                                                    {env} ({groupedServers[env]?.length || 0})
                                                </button>
                                            ))}
                                        </div>
                                    </div>
                                    <div className="overflow-x-auto">
                                        <table className="w-full">
                                            <thead>
                                                <tr className="border-b border-gray-800">
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">负责人</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">项目编码</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">用途</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">IP</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">配置</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {(groupedServers[activeEnv] || []).map(server => (
                                                    <tr key={server.id} className="border-b border-gray-800 hover:bg-gray-800/50 cursor-pointer transition-colors duration-200">
                                                        <td className="py-3 px-4 text-sm">{server.owner}</td>
                                                        <td className="py-3 px-4 font-mono text-sm">{server.project}</td>
                                                        <td className="py-3 px-4 text-sm">{server.usage}</td>
                                                        <td className="py-3 px-4 font-mono text-sm text-gray-400">{server.ip}</td>
                                                        <td className="py-3 px-4 text-sm">{server.config}</td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            )}

                            {activeTab === 'databases' && (
                                <div className="p-6">
                                    <div className="overflow-x-auto">
                                        <table className="w-full">
                                            <thead>
                                                <tr className="border-b border-gray-800">
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">数据库</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">版本</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">平台</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">IP</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">端口</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">用户名</th>
                                                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-400">密码</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {databases.map(db => (
                                                    <tr key={db.id} className="border-b border-gray-800 hover:bg-gray-800/50 cursor-pointer transition-colors duration-200">
                                                        <td className="py-3 px-4 text-sm">{db.name}</td>
                                                        <td className="py-3 px-4 font-mono text-sm">{db.version}</td>
                                                        <td className="py-3 px-4 text-sm">{db.platform}</td>
                                                        <td className="py-3 px-4 font-mono text-sm text-gray-400">{db.ip}</td>
                                                        <td className="py-3 px-4 font-mono text-sm">{db.port}</td>
                                                        <td className="py-3 px-4 font-mono text-sm">{db.user}</td>
                                                        <td className="py-3 px-4 font-mono text-sm text-gray-400">{db.password}</td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>
                )}
            </main>
        </div>
    )
}

export default App
