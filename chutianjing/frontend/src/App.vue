<script setup>
import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <div class="app-container">
    <aside class="sidebar p-4">
      <h1 class="text-xl font-semibold mb-4">楚天镜</h1>
      <nav class="space-y-2 text-sm">
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/overview">全行资产质量信用风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/corporate">公司信用风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/retail">零售信用风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/cards">银行卡风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/region">区域风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/industry">行业风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/group">集团风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/market">金融市场信用风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/portfolio">组合风险预警</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/gen-report">生成式风险报告</RouterLink>
        <RouterLink class="block px-3 py-2 rounded hover:bg-slate-800/60" to="/risk/settings">系统设置及用户管理</RouterLink>
      </nav>
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
</style>
