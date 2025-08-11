<template>
  <div class="card" :class="{ 'card-accent': accent }">
    <div class="flex items-start justify-between">
      <div>
        <div class="text-sm text-slate-300">{{ title }}</div>
        <div :class="valueClass">{{ value }}</div>
        <div class="text-xs text-slate-400">目标缺口：{{ gap }}</div>
      </div>
      <canvas v-if="chart" ref="canvasRef" class="w-24 h-12"></canvas>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler } from 'chart.js'

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler)

const props = defineProps({
  title: { type: String, required: true },
  value: { type: String, required: true },
  gap: { type: String, required: true },
  big: { type: Boolean, default: false },
  accent: { type: Boolean, default: false },
  chart: { type: Boolean, default: false },
  data: { type: Array, default: () => [10,12,9,11,13,12,14] },
})

const valueClass = props.big ? 'text-3xl font-bold' : 'text-xl font-semibold'

const canvasRef = ref(null)

onMounted(() => {
  if (!props.chart || !canvasRef.value) return
  const ctx = canvasRef.value.getContext('2d')
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: props.data.map((_, i) => i + 1),
      datasets: [{
        data: props.data,
        borderColor: '#22d3ee',
        backgroundColor: 'rgba(34, 211, 238, 0.15)',
        tension: 0.4,
        pointRadius: 0,
        fill: true,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: { x: { display: false }, y: { display: false } },
      elements: { line: { borderWidth: 2 } }
    }
  })
})
</script>