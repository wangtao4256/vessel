import { useEffect } from 'react'
import './App.css'

function App() {

  const handleFetch = async () => {
    try {
      const response = await fetch('http://localhost:3300/api/v1/examples', {
        method: 'GET'
      });

      if (response.ok) {
        console.log('response', response)
      } else {
        console.error('请求错误:', response.statusText);
      }
    } catch (err) {
      console.error('请求错误:', err);
    }
  }

  useEffect(() => {
    handleFetch();
  }, [])

  return (
    <div></div>
  )
}

export default App
