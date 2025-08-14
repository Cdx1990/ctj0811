import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import './style.css'
import App from './App.vue'
import { useAuthStore } from './stores/auth'

const app = createApp(App)
const pinia = createPinia()
app.use(pinia)

const auth = useAuthStore(pinia)
auth.initFromStorage()

router.beforeEach((to, from, next) => {
	const publicPaths = ['/login']
	if (!publicPaths.includes(to.path) && !auth.token) {
		return next('/login')
	}
	next()
})

app.use(router)
app.mount('#app')
