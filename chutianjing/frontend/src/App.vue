<script setup>
import { computed } from 'vue'
import { useAuthStore } from './stores/auth'

const auth = useAuthStore()
const username = computed(() => auth.user?.username || '')

function onLogout() {
	auth.logout()
	location.href = '/login'
}
</script>

<template>
  <div class="app-container">
    <aside class="sidebar p-4">
      <h1 class="text-xl font-semibold mb-1">楚天镜</h1>
      <div class="text-xs text-slate-400 mb-3" v-if="username">已登录：{{ username }}</div>
      <nav class="space-y-2 text-sm">
        <RouterLink class="nav-link" to="/risk/overview">全行资产质量信用风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/corporate">公司信用风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/retail">零售信用风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/cards">银行卡风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/region">区域风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/industry">行业风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/group">集团风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/market">金融市场信用风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/portfolio">组合风险预警</RouterLink>
        <RouterLink class="nav-link" to="/risk/gen-report">生成式风险报告</RouterLink>
        <RouterLink class="nav-link" to="/risk/settings">系统设置及用户管理</RouterLink>
      </nav>
		<button v-if="username" @click="onLogout" class="mt-4 w-full text-left text-xs px-3 py-2 rounded bg-slate-900/60 border border-slate-800 hover:bg-slate-800/60">退出登录</button>
    </aside>
    <main class="content">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
.nav-link {
  @apply block px-3 py-2 rounded hover:bg-slate-800/60;
}
.nav-link.router-link-exact-active,
.nav-link.router-link-active {
  @apply underline underline-offset-8 decoration-cyan-400;
}
</style>
