<template>
  <div class="space-y-4">
    <div class="flex items-center gap-3">
      <div class="inline-flex rounded-lg overflow-hidden border border-slate-800">
        <button v-for="t in tabs" :key="t.key" @click="active=t.key"
          class="px-3 py-1.5 text-sm hover:bg-slate-800/60"
          :class="active===t.key ? 'underline underline-offset-8 decoration-cyan-400' : ''">
          {{ t.label }}
        </button>
      </div>
      <div class="ml-auto text-xs text-slate-400">对比时点：较上月</div>
    </div>

    <div class="grid grid-cols-12 gap-4">
      <div class="col-span-8 card card-accent">
        <h2 class="text-sm mb-2">逾期余额</h2>
        <div class="text-3xl font-bold">12.35 亿</div>
        <div class="text-xs text-slate-400">目标缺口：1.20 亿</div>
      </div>
      <div class="col-span-4 card">
        <h2 class="text-sm mb-2">不良余额</h2>
        <div class="text-2xl font-semibold">3.21 亿</div>
        <div class="text-xs text-slate-400">目标缺口：0.30 亿</div>
      </div>
      <div class="col-span-4 card"><h2 class="text-sm">不良率</h2><div class="text-lg">1.42%</div><div class="text-xs text-slate-400">目标缺口：0.12pp</div></div>
      <div class="col-span-4 card"><h2 class="text-sm">逾期率</h2><div class="text-lg">2.03%</div><div class="text-xs text-slate-400">目标缺口：0.20pp</div></div>
      <div class="col-span-4 card"><h2 class="text-sm">准备金</h2><div class="text-lg">45.0 亿</div><div class="text-xs text-slate-400">目标缺口：2.0 亿</div></div>
    </div>

    <router-view />
  </div>
</template>
<script setup>
import { ref } from 'vue'
const tabs = [
  { key: 'overview', label: '全行资产质量' },
  { key: 'corporate', label: '公司' },
  { key: 'retail', label: '零售' },
]
const active = ref('overview')
</script>