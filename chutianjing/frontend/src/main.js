import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import './style.css'
import App from './App.vue'
import axios from 'axios'

// 恢复 Basic 令牌到 axios 默认头
const stored = localStorage.getItem('basicAuth') || sessionStorage.getItem('basicAuth')
if (stored) {
  axios.defaults.headers.common['Authorization'] = stored
}

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
