# vessel-frontend前端项目规范

# React 编码规则
这是vessel-frontend项目的编码规则 请严格遵守
## 1. 组件命名规范

### 组件文件命名
- 使用 PascalCase（大驼峰）命名组件文件
- 例如：`UserProfile.jsx`、`NavigationBar.jsx`

### 组件命名
```jsx
// 推荐
function UserProfile() {
  return <div>User Profile</div>;
}

// 不推荐
function userProfile() {
  return <div>User Profile</div>;
}
```

## 2. Props 规范

### Props 命名
- 使用 camelCase（小驼峰）命名 props
- 布尔类型的 props 使用 `is`、`has`、`should` 等前缀

```jsx
// 推荐
<Button 
  onClick={handleClick}
  isDisabled={false}
  hasIcon={true}
  shouldShowLabel={true}
/>

// 不推荐
<Button 
  click={handleClick}
  disabled={false}
/>
```

### Props 解构
```jsx
// 推荐
function UserCard({ name, age, email }) {
  return (
    <div>
      <h2>{name}</h2>
      <p>{age}</p>
      <p>{email}</p>
    </div>
  );
}

// 可接受
function UserCard(props) {
  const { name, age, email } = props;
  return <div>...</div>;
}
```

## 3. 状态管理

### useState 使用规范
```jsx
// 推荐
const [count, setCount] = useState(0);
const [isOpen, setIsOpen] = useState(false);
const [userData, setUserData] = useState(null);

// 命名清晰，set + 状态名
```

### 复杂状态使用 useReducer
```jsx
// 当状态逻辑复杂时
const [state, dispatch] = useReducer(reducer, initialState);
```

## 4. 事件处理

### 事件处理函数命名
- 使用 `handle` 前缀命名事件处理函数
- 使用 `on` 前缀命名 props 中的事件回调

```jsx
// 推荐
function Form() {
  const handleSubmit = (e) => {
    e.preventDefault();
    // 处理提交
  };

  const handleInputChange = (e) => {
    // 处理输入变化
  };

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={handleInputChange} />
    </form>
  );
}
```

## 5. 条件渲染

### 使用三元运算符或逻辑与
```jsx
// 简单条件
{isLoggedIn ? <UserPanel /> : <LoginButton />}

// 仅渲染一个元素
{isLoading && <Spinner />}

// 复杂条件使用函数
function renderContent() {
  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  return <Content data={data} />;
}

return <div>{renderContent()}</div>;
```

## 6. 列表渲染

### 使用 key 属性
```jsx
// 推荐
{users.map(user => (
  <UserCard key={user.id} user={user} />
))}

// 不推荐（避免使用索引作为 key）
{users.map((user, index) => (
  <UserCard key={index} user={user} />
))}
```

## 7. Hooks 使用规范

### Hooks 调用顺序
- 只在函数组件顶层调用 Hooks
- 不要在循环、条件或嵌套函数中调用 Hooks

```jsx
// 推荐
function Component() {
  const [state, setState] = useState(0);
  const value = useMemo(() => expensiveCalculation(), []);
  
  useEffect(() => {
    // 副作用
  }, []);

  return <div>{state}</div>;
}

// 不推荐
function Component() {
  if (condition) {
    const [state, setState] = useState(0); // 错误！
  }
}
```

### useEffect 依赖项
```jsx
// 推荐 - 明确列出所有依赖
useEffect(() => {
  fetchData(userId);
}, [userId]);

// 空依赖数组 - 仅在挂载时执行
useEffect(() => {
  initializeApp();
}, []);
```

## 8. 组件结构

### 推荐的组件结构顺序
```jsx
function MyComponent({ prop1, prop2 }) {
  // 1. Hooks
  const [state, setState] = useState(0);
  const dispatch = useDispatch();
  
  // 2. 派生状态
  const computedValue = useMemo(() => {
    return state * 2;
  }, [state]);
  
  // 3. 副作用
  useEffect(() => {
    // 副作用逻辑
  }, []);
  
  // 4. 事件处理函数
  const handleClick = () => {
    setState(state + 1);
  };
  
  // 5. 渲染辅助函数
  const renderHeader = () => {
    return <header>Header</header>;
  };
  
  // 6. 返回 JSX
  return (
    <div>
      {renderHeader()}
      <button onClick={handleClick}>{state}</button>
    </div>
  );
}
```

## 9. JSX 格式化

### 属性换行
```jsx
// 单个属性
<Button onClick={handleClick} />

// 多个属性换行
<Button
  type="submit"
  disabled={isLoading}
  onClick={handleClick}
  className="primary-button"
>
  Submit
</Button>
```

### 子元素格式
```jsx
// 推荐
<div>
  <Header />
  <Content />
  <Footer />
</div>

// 单行简短内容
<div>Simple text</div>
```

## 10. 性能优化

### 使用 React.memo
```jsx
// 对于纯展示组件
const UserCard = React.memo(({ user }) => {
  return (
    <div>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
    </div>
  );
});
```

### 使用 useCallback 和 useMemo
```jsx
// useCallback 缓存函数
const handleClick = useCallback(() => {
  doSomething(value);
}, [value]);

// useMemo 缓存计算结果
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(a, b);
}, [a, b]);
```

## 11. TypeScript 类型定义（可选）

```tsx
// Props 类型定义
interface ButtonProps {
  onClick: () => void;
  disabled?: boolean;
  children: React.ReactNode;
}

function Button({ onClick, disabled = false, children }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled}>
      {children}
    </button>
  );
}
```

## 12. 注释规范

```jsx
/**
 * 用户资料卡片组件
 * @param {Object} user - 用户信息对象
 * @param {Function} onEdit - 编辑回调函数
 */
function UserProfileCard({ user, onEdit }) {
  // 处理编辑操作
  const handleEdit = () => {
    onEdit(user.id);
  };

  return (
    <div className="user-card">
      {/* 用户头像区域 */}
      <img src={user.avatar} alt={user.name} />
      
      {/* 用户信息 */}
      <div className="user-info">
        <h3>{user.name}</h3>
        <p>{user.email}</p>
      </div>
    </div>
  );
}
```

## 13. 文件组织

```
src/
  components/
    common/          # 通用组件
      Button/
        Button.jsx
        Button.css
        index.js
    features/        # 功能组件
      UserProfile/
        UserProfile.jsx
        UserProfile.css
        index.js
  hooks/            # 自定义 Hooks
    useAuth.js
    useFetch.js
  utils/            # 工具函数
  constants/        # 常量定义
```

## 14. 最佳实践总结

1. **保持组件小而专注** - 单一职责原则
2. **避免过度嵌套** - 提取子组件
3. **使用 PropTypes 或 TypeScript** - 类型检查
4. **避免在 JSX 中写复杂逻辑** - 提取到函数中
5. **合理使用 Fragment** - 避免不必要的 div 包裹
6. **使用解构赋值** - 提高代码可读性
7. **遵循 ESLint 规则** - 保持代码一致性
8. **编写可测试的组件** - 便于单元测试

---

遵循这些编码规则可以帮助你编写更清晰、可维护和高性能的 React 应用程序。
