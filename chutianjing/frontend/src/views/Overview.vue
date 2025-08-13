<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold">全行资产质量信用风险预警 · 概览</h2>

    <div class="card">
      <div class="grid grid-cols-12 gap-3 text-sm">
        <select class="bg-slate-800/60 rounded px-3 py-2 col-span-2">
          <option>AB市</option>
          <option>CD地市州</option>
          <option>全省汇总</option>
        </select>
        <select class="bg-slate-800/60 rounded px-3 py-2 col-span-2">
          <option>公司（含对公普惠）</option>
          <option>消金（含对私普惠）</option>
          <option>交易银行</option>
          <option>银行卡</option>
        </select>
        <select class="bg-slate-800/60 rounded px-3 py-2 col-span-2">
          <option>二级机构A1</option><option>B1</option><option>C1</option>
        </select>
        <select class="bg-slate-800/60 rounded px-3 py-2 col-span-2">
          <option>较上日</option>
          <option selected>较上月</option>
          <option>较上季</option>
          <option>较上年</option>
        </select>
        <div class="col-span-3 flex items-center gap-2">
          <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox" checked> 表内余额</label>
          <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox" checked> 逾期</label>
          <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox" checked> 不良</label>
          <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox"> 新发生不良</label>
          <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox"> 准备金</label>
        </div>
        <button class="bg-cyan-600 hover:bg-cyan-500 rounded px-4 py-2 text-xs col-span-1">查询</button>
      </div>
    </div>

    <div class="grid grid-cols-12 gap-4">
      <div class="col-span-8">
        <MetricCard title="逾期余额" value="12.35 亿" gap="1.20 亿" big accent chart :data="[10,12,13,11,14,15,13]" />
      </div>
      <div class="col-span-4">
        <MetricCard title="不良余额" value="3.21 亿" gap="0.30 亿" />
      </div>
      <div class="col-span-4"><MetricCard title="不良率" value="1.42%" gap="0.12pp" chart /></div>
      <div class="col-span-4"><MetricCard title="逾期率" value="2.03%" gap="0.20pp" chart /></div>
      <div class="col-span-4"><MetricCard title="准备金" value="45.0 亿" gap="2.0 亿" /></div>
    </div>
  </div>
</template>

<script setup>
import MetricCard from '../components/MetricCard.vue'
</script>