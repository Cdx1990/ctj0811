<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'

const route = useRoute()
const isFullPage = computed(() => route.meta?.fullPage === true)
</script>

<template>
  <div v-if="isFullPage">
    <RouterView />
  </div>
  <div v-else class="app-container">
    <aside class="sidebar p-4">
      <h1 class="text-xl font-semibold mb-4">楚天镜</h1>
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
        <RouterLink class="nav-link" to="/dashboard">智能风控 · 总览大屏</RouterLink>
      </nav>
    </aside>
    <main class="content">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.logo { height: 6em; padding: 1.5em; will-change: filter; transition: filter 300ms; }
.logo:hover { filter: drop-shadow(0 0 2em #646cffaa); }
.logo.vue:hover { filter: drop-shadow(0 0 2em #42b883aa); }
.nav-link { @apply block px-3 py-2 rounded hover:bg-slate-800/60; }
.nav-link.router-link-exact-active,
.nav-link.router-link-active { @apply underline underline-offset-8 decoration-cyan-400; }
</style>
