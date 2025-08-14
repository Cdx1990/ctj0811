<script setup>
import { computed } from 'vue'
import apiClient from '../api/client'
import { useAuthStore } from '../stores/auth'

const auth = useAuthStore()
const user = computed(() => auth.user)

async function testPing() {
	const { data } = await apiClient.get('/risk/ping')
	alert(JSON.stringify(data))
}
</script>

<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold">系统设置及用户管理</h2>
    <div class="card">
      <div class="text-sm">当前用户</div>
      <pre class="text-xs mt-2">{{ user }}</pre>
    </div>
    <div class="card">
      <div class="text-sm mb-2">联通性测试</div>
      <button @click="testPing" class="px-3 py-1.5 bg-cyan-600 rounded hover:bg-cyan-500 text-sm">调用 /api/risk/ping</button>
    </div>
  </div>
</template>