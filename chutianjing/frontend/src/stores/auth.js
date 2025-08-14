import { defineStore } from 'pinia'
import apiClient, { setAuthToken } from '../api/client'

function toBase64(str) {
	if (typeof btoa !== 'undefined') return btoa(str)
	return Buffer.from(str, 'utf8').toString('base64')
}

export const useAuthStore = defineStore('auth', {
	state: () => ({
		username: '',
		password: '',
		token: '',
		user: null,
		loading: false,
		error: '',
	}),
	actions: {
		async login(username, password) {
			this.loading = true
			this.error = ''
			try {
				const basic = toBase64(`${username}:${password}`)
				this.token = basic
				setAuthToken(basic)
				const { data } = await apiClient.get('/auth/me')
				this.user = data
				this.username = username
				this.password = password
				localStorage.setItem('auth_token', basic)
			} catch (e) {
				this.user = null
				this.token = ''
				setAuthToken('')
				this.error = '登录失败，请检查用户名或密码'
				throw e
			} finally {
				this.loading = false
			}
		},
		logout() {
			this.user = null
			this.username = ''
			this.password = ''
			this.token = ''
			setAuthToken('')
			localStorage.removeItem('auth_token')
		},
		initFromStorage() {
			const saved = localStorage.getItem('auth_token')
			if (saved) {
				this.token = saved
				setAuthToken(saved)
			}
		},
	},
})