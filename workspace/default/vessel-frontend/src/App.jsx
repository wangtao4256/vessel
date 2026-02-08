import './App.css'

function App() {
    return (
        <div className="welcome-container">
            <div className="welcome-card">
                <div className="welcome-icon">👋</div>
                <h1 className="welcome-title">欢迎使用</h1>
                <p className="welcome-subtitle">开始构建你的精彩应用</p>
                <div className="welcome-divider"></div>
                <p className="welcome-desc">
                    默认项目 现代化的 React 应用脚手架，集成了 FastAPI 后端服务。
                </p>
            </div>
        </div>
    )
}

export default App
