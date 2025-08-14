<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const auth = useAuthStore()
const username = ref('')
const password = ref('')

async function onSubmit() {
	try {
		await auth.login(username.value, password.value)
		router.replace('/risk/overview')
	} catch (e) {
		// error handled in store
	}
}
</script>

<template>
	<div class="min-h-screen flex items-center justify-center">
		<form class="w-full max-w-sm space-y-4 card" @submit.prevent="onSubmit">
			<h1 class="text-xl font-semibold text-center">登录</h1>
			<div>
				<label class="block text-sm mb-1">用户名</label>
				<input v-model="username" class="w-full px-3 py-2 bg-slate-900 rounded border border-slate-700" />
			</div>
			<div>
				<label class="block text-sm mb-1">密码</label>
				<input v-model="password" type="password" class="w-full px-3 py-2 bg-slate-900 rounded border border-slate-700" />
			</div>
			<div v-if="auth.error" class="text-red-400 text-sm">{{ auth.error }}</div>
			<button :disabled="auth.loading" class="w-full px-3 py-2 bg-cyan-600 rounded hover:bg-cyan-500 disabled:opacity-50">
				{{ auth.loading ? '登录中...' : '登录' }}
			</button>
			<p class="text-xs text-center text-slate-400">默认账号 hbctj1995 / code123</p>
		</form>
	</div>
</template>

<style scoped>
.card { @apply bg-slate-900/60 p-5 rounded border border-slate-800; }
</style>