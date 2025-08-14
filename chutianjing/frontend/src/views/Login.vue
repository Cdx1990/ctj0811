<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const router = useRouter()
const username = ref('')
const password = ref('')
const remember = ref(true)
const loading = ref(false)
const errorMsg = ref('')

async function login() {
  errorMsg.value = ''
  if (!username.value || !password.value) {
    errorMsg.value = '请输入用户名和密码'
    return
  }
  loading.value = true
  try {
    const basic = 'Basic ' + btoa(username.value + ':' + password.value)
    await axios.get('/api/auth/me', { headers: { Authorization: basic } })
    if (remember.value) {
      localStorage.setItem('basicAuth', basic)
    } else {
      sessionStorage.setItem('basicAuth', basic)
    }
    axios.defaults.headers.common['Authorization'] = basic
    router.replace('/dashboard')
  } catch (e) {
    errorMsg.value = '登录失败：账号或密码错误'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-slate-950 text-slate-100 flex items-center justify-center p-6">
    <div class="w-full max-w-md glass rounded-xl border border-slate-800/60 p-6 shadow-xl">
      <div class="flex items-center mb-6">
        <div class="w-10 h-10 rounded-lg bg-gradient-to-r from-cyan-400 to-violet-500 flex items-center justify-center mr-3">
          <i class="fas fa-shield-alt"></i>
        </div>
        <div>
          <div class="text-lg font-semibold">楚天镜 · 智能风控系统</div>
          <div class="text-xs text-slate-400">登录平台</div>
        </div>
      </div>

      <form @submit.prevent="login" class="space-y-4">
        <div>
          <label class="block text-xs mb-1 text-slate-400">用户名</label>
          <input v-model="username" type="text" autocomplete="username" class="w-full bg-slate-900/70 border border-slate-800 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-cyan-400" placeholder="请输入用户名" />
        </div>
        <div>
          <label class="block text-xs mb-1 text-slate-400">密码</label>
          <input v-model="password" type="password" autocomplete="current-password" class="w-full bg-slate-900/70 border border-slate-800 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-cyan-400" placeholder="请输入密码" />
        </div>
        <div class="flex items-center justify-between text-xs text-slate-400">
          <label class="inline-flex items-center gap-2">
            <input v-model="remember" type="checkbox" class="accent-cyan-400" /> 记住我
          </label>
          <a class="hover:underline hover:text-slate-200" href="#">忘记密码?</a>
        </div>
        <button :disabled="loading" type="submit" class="w-full bg-cyan-500 hover:bg-cyan-400 disabled:opacity-60 disabled:cursor-not-allowed text-slate-950 font-medium rounded-lg py-2 transition-colors">
          <span v-if="!loading">登录</span>
          <span v-else class="inline-flex items-center gap-2"><i class="fas fa-spinner animate-spin"></i> 登录中...</span>
        </button>
        <p v-if="errorMsg" class="text-rose-400 text-xs">{{ errorMsg }}</p>
        <div class="text-[10px] text-slate-500 mt-2">开发环境默认账号：hbctj1995 / code123</div>
      </form>
    </div>
  </div>
</template>

<style scoped>
.glass { backdrop-filter: blur(10px); background-color: rgba(2,6,23,0.6); }
</style>