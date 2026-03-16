import { useState, useEffect } from 'react'
import { Layout, Menu, Card, Table, Statistic, Row, Col, Tabs, Button } from 'antd'
import { HomeOutlined, CloudServerOutlined, DatabaseOutlined, LogoutOutlined } from '@ant-design/icons'
import Login from './Login'
import './App.css'

const { Header, Content } = Layout

function App() {
    const [isLoggedIn, setIsLoggedIn] = useState(false)
    const [activeMenu, setActiveMenu] = useState('home')
    const [activeSubMenu, setActiveSubMenu] = useState('servers')
    const [activeTab, setActiveTab] = useState('线上演示环境')
    const [serverStats, setServerStats] = useState({})
    const [servers, setServers] = useState({})
    const [dbStats, setDbStats] = useState({})
    const [databases, setDatabases] = useState([])

    useEffect(() => {
        const token = localStorage.getItem('token')
        setIsLoggedIn(!!token)
    }, [])

    const fetchData = async () => {
        try {
            const [statsRes, serversRes, dbStatsRes, dbRes] = await Promise.all([
                fetch('/api/v1/server/servers/stats'),
                fetch('/api/v1/server/servers'),
                fetch('/api/v1/server/databases/stats'),
                fetch('/api/v1/server/databases')
            ])
            const statsData = await statsRes.json()
            const serversData = await serversRes.json()
            const dbStatsData = await dbStatsRes.json()
            const dbData = await dbRes.json()
            
            setServerStats(statsData.data)
            setServers(serversData.data)
            setDbStats(dbStatsData.data)
            setDatabases(dbData.data)
        } catch (error) {
            console.error('获取数据失败:', error)
        }
    }

    useEffect(() => {
        fetchData()
    }, [])

    const serverColumns = [
        { title: '负责人', dataIndex: 'owner', key: 'owner', width: 100 },
        { title: '项目编码', dataIndex: 'project', key: 'project', width: 120 },
        { title: '用途', dataIndex: 'usage', key: 'usage' },
        { title: 'IP', dataIndex: 'ip', key: 'ip', width: 140 },
        { title: '配置', dataIndex: 'config', key: 'config', width: 80 },
    ]

    const dbColumns = [
        { title: '数据库', dataIndex: 'name', key: 'name', width: 150 },
        { title: '版本', dataIndex: 'version', key: 'version', width: 120 },
        { title: '平台', dataIndex: 'platform', key: 'platform', width: 100 },
        { title: 'IP', dataIndex: 'ip', key: 'ip', width: 140 },
        { title: '端口', dataIndex: 'port', key: 'port', width: 80 },
        { title: '用户名', dataIndex: 'user', key: 'user', width: 100 },
        { title: '密码', dataIndex: 'password', key: 'password', width: 120 },
    ]

    const renderHome = () => (
        <div>
            <h2 style={{ marginBottom: 24 }}>服务器统计</h2>
            <Row gutter={16}>
                <Col span={4}>
                    <Card><Statistic title="总计" value={serverStats.total || 0} suffix="台" /></Card>
                </Col>
                <Col span={4}>
                    <Card hoverable onClick={() => { setActiveTab('线上演示环境'); setActiveSubMenu('servers'); setActiveMenu('ops'); }} style={{ cursor: 'pointer' }}>
                        <Statistic title="线上演示" value={serverStats['线上演示环境'] || 0} suffix="台" />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card hoverable onClick={() => { setActiveTab('开发环境'); setActiveSubMenu('servers'); setActiveMenu('ops'); }} style={{ cursor: 'pointer' }}>
                        <Statistic title="开发环境" value={serverStats['开发环境'] || 0} suffix="台" />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card hoverable onClick={() => { setActiveTab('运维环境'); setActiveSubMenu('servers'); setActiveMenu('ops'); }} style={{ cursor: 'pointer' }}>
                        <Statistic title="运维环境" value={serverStats['运维环境'] || 0} suffix="台" />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card hoverable onClick={() => { setActiveTab('GPU环境'); setActiveSubMenu('servers'); setActiveMenu('ops'); }} style={{ cursor: 'pointer' }}>
                        <Statistic title="GPU环境" value={serverStats['GPU环境'] || 0} suffix="台" />
                    </Card>
                </Col>
            </Row>
            <h2 style={{ marginTop: 40, marginBottom: 24 }}>数据库统计</h2>
            <Row gutter={16}>
                <Col span={6}>
                    <Card hoverable onClick={() => { setActiveSubMenu('databases'); setActiveMenu('ops'); }} style={{ cursor: 'pointer' }}>
                        <Statistic title="数据库总数" value={dbStats.total || 0} suffix="个" />
                    </Card>
                </Col>
            </Row>
        </div>
    )

    const renderServers = () => {
        const items = Object.entries(servers).map(([env, list]) => ({
            key: env,
            label: `${env} (${list.length})`,
            children: <Table columns={serverColumns} dataSource={list} rowKey="id" pagination={{ pageSize: 10 }} size="small" />
        }))
        return <Tabs activeKey={activeTab} onChange={setActiveTab} items={items} />
    }

    const renderDatabases = () => (
        <Table columns={dbColumns} dataSource={databases} rowKey="id" pagination={{ pageSize: 15 }} size="small" />
    )

    const renderOps = () => (
        <Tabs activeKey={activeSubMenu} onChange={setActiveSubMenu}>
            <Tabs.TabPane tab="服务器管理" key="servers">
                {renderServers()}
            </Tabs.TabPane>
            <Tabs.TabPane tab="数据库管理" key="databases">
                {renderDatabases()}
            </Tabs.TabPane>
        </Tabs>
    )

    const handleLogout = () => {
        localStorage.removeItem('token')
        setIsLoggedIn(false)
    }

    if (!isLoggedIn) {
        return <Login onLoginSuccess={() => setIsLoggedIn(true)} />
    }

    return (
        <Layout style={{ minHeight: '100vh' }}>
            <Header style={{ background: '#001529', padding: '0 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ color: 'white', fontSize: 20, fontWeight: 'bold' }}>
                    服务器信息管理平台
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
                    <Menu
                        theme="dark"
                        mode="horizontal"
                        selectedKeys={[activeMenu]}
                        onClick={e => setActiveMenu(e.key)}
                        style={{ flex: 1, minWidth: 0 }}
                    >
                        <Menu.Item key="home" icon={<HomeOutlined />}>首页</Menu.Item>
                        <Menu.Item key="ops" icon={<CloudServerOutlined />}>运维管理</Menu.Item>
                    </Menu>
                    <Button type="text" icon={<LogoutOutlined />} onClick={handleLogout} style={{ color: 'white' }}>
                        退出
                    </Button>
                </div>
            </Header>
            <Content style={{ padding: 24, background: '#f0f2f5' }}>
                {activeMenu === 'home' && renderHome()}
                {activeMenu === 'ops' && renderOps()}
            </Content>
        </Layout>
    )
}

export default App
