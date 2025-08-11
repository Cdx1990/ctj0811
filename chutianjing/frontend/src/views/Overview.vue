<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold">全行资产质量信用风险预警 · 概览</h2>
    <div class="grid grid-cols-12 gap-4">
      <div class="col-span-12 card">
        <div class="text-sm text-slate-400 mb-2">筛选条件</div>
        <div class="grid grid-cols-6 gap-3 text-sm">
          <select class="bg-slate-800/60 rounded px-3 py-2 col-span-1">
            <option>AB市</option>
            <option>CD地市州</option>
            <option>全省汇总</option>
          </select>
          <select class="bg-slate-800/60 rounded px-3 py-2 col-span-1">
            <option>公司</option>
            <option>消金</option>
            <option>交易银行</option>
            <option>银行卡</option>
          </select>
          <select class="bg-slate-800/60 rounded px-3 py-2 col-span-1">
            <option>较上日</option>
            <option>较上月</option>
            <option>较上季</option>
            <option>较上年</option>
          </select>
          <div class="col-span-2 flex items-center gap-2">
            <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox" checked> 表内余额</label>
            <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox" checked> 逾期</label>
            <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox" checked> 不良</label>
            <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox"> 新发生不良</label>
            <label class="inline-flex items-center gap-1 text-xs"><input type="checkbox"> 准备金</label>
          </div>
          <button class="bg-cyan-600 hover:bg-cyan-500 rounded px-4 py-2 text-xs">查询</button>
        </div>
      </div>
    </div>
  </div>
</template>