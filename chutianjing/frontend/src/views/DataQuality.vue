<template>
  <div class="data-quality-dashboard">
    <!-- 页面标题和操作栏 -->
    <div class="dashboard-header">
      <div class="header-content">
        <h1 class="dashboard-title">
          <span class="title-icon">📊</span>
          数据资产质量分析
        </h1>
        <div class="header-actions">
          <button @click="exportToExcel" class="export-btn">
            <span class="btn-icon">📥</span>
            导出完整报告
          </button>
          <button @click="exportSimpleExcel" class="export-btn simple">
            <span class="btn-icon">📋</span>
            导出简化版
          </button>
          <button @click="refreshData" class="refresh-btn">
            <span class="btn-icon">🔄</span>
            刷新数据
          </button>
        </div>
      </div>
    </div>

    <!-- 筛选条件 -->
    <div class="filter-section">
      <div class="filter-grid">
        <div class="filter-item">
          <label>数据源</label>
          <select v-model="filters.dataSource" class="filter-select">
            <option value="all">全部数据源</option>
            <option value="core">核心业务系统</option>
            <option value="risk">风险管理系统</option>
            <option value="finance">财务系统</option>
            <option value="customer">客户管理系统</option>
          </select>
        </div>
        <div class="filter-item">
          <label>质量维度</label>
          <select v-model="filters.qualityDimension" class="filter-select">
            <option value="all">全部维度</option>
            <option value="completeness">完整性</option>
            <option value="accuracy">准确性</option>
            <option value="consistency">一致性</option>
            <option value="timeliness">及时性</option>
            <option value="validity">有效性</option>
          </select>
        </div>
        <div class="filter-item">
          <label>时间范围</label>
          <select v-model="filters.timeRange" class="filter-select">
            <option value="today">今日</option>
            <option value="week">本周</option>
            <option value="month" selected>本月</option>
            <option value="quarter">本季度</option>
            <option value="year">本年</option>
          </select>
        </div>
        <div class="filter-item">
          <label>质量等级</label>
          <select v-model="filters.qualityLevel" class="filter-select">
            <option value="all">全部等级</option>
            <option value="excellent">优秀 (90%+)</option>
            <option value="good">良好 (80-90%)</option>
            <option value="fair">一般 (70-80%)</option>
            <option value="poor">较差 (<70%)</option>
          </select>
        </div>
      </div>
    </div>

    <!-- 关键指标卡片 -->
    <div class="metrics-grid">
      <div class="metric-card primary">
        <div class="metric-icon">🎯</div>
        <div class="metric-content">
          <div class="metric-value">{{ metrics.overallScore }}%</div>
          <div class="metric-label">整体质量评分</div>
          <div class="metric-trend positive">+2.3%</div>
        </div>
      </div>
      <div class="metric-card">
        <div class="metric-icon">📈</div>
        <div class="metric-content">
          <div class="metric-value">{{ metrics.dataVolume }}</div>
          <div class="metric-label">数据总量</div>
          <div class="metric-trend positive">+5.2%</div>
        </div>
      </div>
      <div class="metric-card">
        <div class="metric-icon">⚠️</div>
        <div class="metric-content">
          <div class="metric-value">{{ metrics.issuesCount }}</div>
          <div class="metric-label">质量问题数</div>
          <div class="metric-trend negative">-12.5%</div>
        </div>
      </div>
      <div class="metric-card">
        <div class="metric-icon">✅</div>
        <div class="metric-content">
          <div class="metric-value">{{ metrics.complianceRate }}%</div>
          <div class="metric-label">合规率</div>
          <div class="metric-trend positive">+1.8%</div>
        </div>
      </div>
    </div>

    <!-- 图表区域 -->
    <div class="charts-section">
      <div class="chart-row">
        <div class="chart-card large">
          <div class="chart-header">
            <h3>质量趋势分析</h3>
            <div class="chart-actions">
              <button @click="toggleChartView('trend')" class="chart-btn">切换视图</button>
            </div>
          </div>
          <div class="chart-container">
            <canvas ref="trendChart" class="chart-canvas"></canvas>
          </div>
        </div>
        <div class="chart-card">
          <div class="chart-header">
            <h3>质量维度分布</h3>
          </div>
          <div class="chart-container">
            <canvas ref="dimensionChart" class="chart-canvas"></canvas>
          </div>
        </div>
      </div>
      
      <div class="chart-row">
        <div class="chart-card">
          <div class="chart-header">
            <h3>数据源质量排名</h3>
          </div>
          <div class="chart-container">
            <canvas ref="rankingChart" class="chart-canvas"></canvas>
          </div>
        </div>
        <div class="chart-card">
          <div class="chart-header">
            <h3>问题类型分布</h3>
          </div>
          <div class="chart-container">
            <canvas ref="issueChart" class="chart-canvas"></canvas>
          </div>
        </div>
      </div>
    </div>

    <!-- 数据表格 -->
    <div class="table-section">
      <div class="table-header">
        <h3>详细质量报告</h3>
        <div class="table-actions">
          <input v-model="tableSearch" placeholder="搜索..." class="search-input" />
          <select v-model="tableSortBy" class="sort-select">
            <option value="score">按评分排序</option>
            <option value="name">按名称排序</option>
            <option value="issues">按问题数排序</option>
          </select>
        </div>
      </div>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>数据资产</th>
              <th>质量评分</th>
              <th>完整性</th>
              <th>准确性</th>
              <th>一致性</th>
              <th>及时性</th>
              <th>问题数</th>
              <th>状态</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in filteredTableData" :key="item.id" class="table-row">
              <td class="asset-name">{{ item.name }}</td>
              <td>
                <div class="score-cell">
                  <span class="score-value">{{ item.score }}%</span>
                  <div class="score-bar">
                    <div class="score-fill" :style="{ width: item.score + '%', backgroundColor: getScoreColor(item.score) }"></div>
                  </div>
                </div>
              </td>
              <td>{{ item.completeness }}%</td>
              <td>{{ item.accuracy }}%</td>
              <td>{{ item.consistency }}%</td>
              <td>{{ item.timeliness }}%</td>
              <td>{{ item.issues }}</td>
              <td>
                <span class="status-badge" :class="getStatusClass(item.status)">
                  {{ item.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler, BarController, BarElement, DoughnutController, ArcElement, Tooltip, Legend } from 'chart.js'
import { generateDataQualityReport, generateSimpleReport } from '../utils/excelTemplate.js'

// 注册Chart.js组件
Chart.register(
  LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler,
  BarController, BarElement, DoughnutController, ArcElement, Tooltip, Legend
)

// 响应式数据
const filters = ref({
  dataSource: 'all',
  qualityDimension: 'all',
  timeRange: 'month',
  qualityLevel: 'all'
})

const metrics = ref({
  overallScore: 87.5,
  dataVolume: '2.3TB',
  issuesCount: 156,
  complianceRate: 94.2
})

const tableSearch = ref('')
const tableSortBy = ref('score')

// 图表引用
const trendChart = ref(null)
const dimensionChart = ref(null)
const rankingChart = ref(null)
const issueChart = ref(null)

// 模拟数据
const tableData = ref([
  { id: 1, name: '客户基础信息', score: 92, completeness: 95, accuracy: 89, consistency: 94, timeliness: 90, issues: 8, status: '优秀' },
  { id: 2, name: '交易流水数据', score: 88, completeness: 92, accuracy: 85, consistency: 90, timeliness: 85, issues: 15, status: '良好' },
  { id: 3, name: '风险评级数据', score: 95, completeness: 98, accuracy: 93, consistency: 96, timeliness: 92, issues: 5, status: '优秀' },
  { id: 4, name: '产品配置信息', score: 82, completeness: 88, accuracy: 80, consistency: 85, timeliness: 75, issues: 23, status: '一般' },
  { id: 5, name: '财务核算数据', score: 90, completeness: 93, accuracy: 88, consistency: 92, timeliness: 87, issues: 12, status: '良好' },
  { id: 6, name: '监管报送数据', score: 97, completeness: 99, accuracy: 96, consistency: 98, timeliness: 94, issues: 3, status: '优秀' },
  { id: 7, name: '营销活动数据', score: 78, completeness: 85, accuracy: 75, consistency: 80, timeliness: 70, issues: 31, status: '一般' },
  { id: 8, name: '系统日志数据', score: 85, completeness: 90, accuracy: 82, consistency: 88, timeliness: 80, issues: 18, status: '良好' }
])

// 计算属性
const filteredTableData = computed(() => {
  let filtered = tableData.value

  // 搜索过滤
  if (tableSearch.value) {
    filtered = filtered.filter(item => 
      item.name.toLowerCase().includes(tableSearch.value.toLowerCase())
    )
  }

  // 排序
  filtered.sort((a, b) => {
    switch (tableSortBy.value) {
      case 'score':
        return b.score - a.score
      case 'name':
        return a.name.localeCompare(b.name)
      case 'issues':
        return a.issues - b.issues
      default:
        return 0
    }
  })

  return filtered
})

// 方法
const getScoreColor = (score) => {
  if (score >= 90) return '#10b981'
  if (score >= 80) return '#3b82f6'
  if (score >= 70) return '#f59e0b'
  return '#ef4444'
}

const getStatusClass = (status) => {
  switch (status) {
    case '优秀': return 'status-excellent'
    case '良好': return 'status-good'
    case '一般': return 'status-fair'
    case '较差': return 'status-poor'
    default: return ''
  }
}

const exportToExcel = () => {
  // 准备导出数据
  const exportData = {
    overallScore: metrics.value.overallScore,
    dataVolume: metrics.value.dataVolume,
    issuesCount: metrics.value.issuesCount,
    complianceRate: metrics.value.complianceRate,
    tableData: filteredTableData.value
  }

  // 生成完整版Excel报告
  generateDataQualityReport(exportData)
}

const exportSimpleExcel = () => {
  // 准备导出数据
  const exportData = {
    overallScore: metrics.value.overallScore,
    dataVolume: metrics.value.dataVolume,
    issuesCount: metrics.value.issuesCount,
    complianceRate: metrics.value.complianceRate,
    tableData: filteredTableData.value
  }

  // 生成简化版Excel报告
  generateSimpleReport(exportData)
}

const refreshData = () => {
  // 模拟数据刷新
  console.log('刷新数据...')
  // 这里可以调用API获取最新数据
}

const toggleChartView = (chartType) => {
  console.log('切换图表视图:', chartType)
  // 这里可以实现图表视图切换逻辑
}

// 初始化图表
const initCharts = () => {
  // 趋势图表
  if (trendChart.value) {
    new Chart(trendChart.value.getContext('2d'), {
      type: 'line',
      data: {
        labels: ['1月', '2月', '3月', '4月', '5月', '6月'],
        datasets: [{
          label: '整体质量评分',
          data: [82, 84, 86, 85, 87, 87.5],
          borderColor: '#3b82f6',
          backgroundColor: 'rgba(59, 130, 246, 0.1)',
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: false,
            min: 75,
            max: 95,
            grid: { color: 'rgba(255, 255, 255, 0.1)' },
            ticks: { color: '#9ca3af' }
          },
          x: {
            grid: { color: 'rgba(255, 255, 255, 0.1)' },
            ticks: { color: '#9ca3af' }
          }
        }
      }
    })
  }

  // 维度分布图表
  if (dimensionChart.value) {
    new Chart(dimensionChart.value.getContext('2d'), {
      type: 'doughnut',
      data: {
        labels: ['完整性', '准确性', '一致性', '及时性', '有效性'],
        datasets: [{
          data: [92, 85, 89, 82, 88],
          backgroundColor: [
            '#10b981',
            '#3b82f6',
            '#f59e0b',
            '#ef4444',
            '#8b5cf6'
          ]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: { color: '#9ca3af' }
          }
        }
      }
    })
  }

  // 排名图表
  if (rankingChart.value) {
    new Chart(rankingChart.value.getContext('2d'), {
      type: 'bar',
      data: {
        labels: ['监管报送', '风险评级', '客户基础', '财务核算', '交易流水'],
        datasets: [{
          label: '质量评分',
          data: [97, 95, 92, 90, 88],
          backgroundColor: '#3b82f6'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: 'y',
        plugins: {
          legend: { display: false }
        },
        scales: {
          x: {
            beginAtZero: false,
            min: 80,
            max: 100,
            grid: { color: 'rgba(255, 255, 255, 0.1)' },
            ticks: { color: '#9ca3af' }
          },
          y: {
            grid: { color: 'rgba(255, 255, 255, 0.1)' },
            ticks: { color: '#9ca3af' }
          }
        }
      }
    })
  }

  // 问题类型图表
  if (issueChart.value) {
    new Chart(issueChart.value.getContext('2d'), {
      type: 'doughnut',
      data: {
        labels: ['数据缺失', '格式错误', '重复数据', '过期数据', '逻辑错误'],
        datasets: [{
          data: [35, 25, 20, 15, 5],
          backgroundColor: [
            '#ef4444',
            '#f59e0b',
            '#3b82f6',
            '#8b5cf6',
            '#10b981'
          ]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: { color: '#9ca3af' }
          }
        }
      }
    })
  }
}

// 监听筛选条件变化
watch(filters, () => {
  // 这里可以根据筛选条件重新获取数据
  console.log('筛选条件变化:', filters.value)
}, { deep: true })

onMounted(() => {
  initCharts()
})
</script>

<style scoped>
.data-quality-dashboard {
  @apply space-y-6;
}

.dashboard-header {
  @apply bg-gradient-to-r from-slate-900 to-slate-800 rounded-xl border border-slate-700/50 backdrop-blur-sm;
}

.header-content {
  @apply flex justify-between items-center p-6;
}

.dashboard-title {
  @apply text-2xl font-bold text-white flex items-center gap-3;
}

.title-icon {
  @apply text-3xl;
}

.header-actions {
  @apply flex gap-3;
}

.export-btn, .refresh-btn {
  @apply flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all duration-200;
}

.export-btn {
  @apply bg-gradient-to-r from-cyan-600 to-blue-600 hover:from-cyan-500 hover:to-blue-500 text-white shadow-lg hover:shadow-xl;
}

.export-btn.simple {
  @apply bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-500 hover:to-emerald-500;
}

.refresh-btn {
  @apply bg-slate-700 hover:bg-slate-600 text-slate-200 border border-slate-600;
}

.btn-icon {
  @apply text-lg;
}

.filter-section {
  @apply bg-slate-900/50 backdrop-blur border border-slate-800/60 rounded-xl p-6;
}

.filter-grid {
  @apply grid grid-cols-4 gap-4;
}

.filter-item {
  @apply space-y-2;
}

.filter-item label {
  @apply block text-sm font-medium text-slate-300;
}

.filter-select {
  @apply w-full bg-slate-800/60 border border-slate-700 rounded-lg px-3 py-2 text-slate-200 focus:ring-2 focus:ring-cyan-500 focus:border-transparent;
}

.metrics-grid {
  @apply grid grid-cols-4 gap-4;
}

.metric-card {
  @apply bg-gradient-to-br from-slate-900/80 to-slate-800/80 backdrop-blur border border-slate-700/50 rounded-xl p-6 transition-all duration-300 hover:shadow-lg hover:border-slate-600/50;
}

.metric-card.primary {
  @apply bg-gradient-to-br from-cyan-900/80 to-blue-900/80 border-cyan-700/50;
}

.metric-icon {
  @apply text-3xl mb-3;
}

.metric-value {
  @apply text-3xl font-bold text-white mb-1;
}

.metric-label {
  @apply text-sm text-slate-400 mb-2;
}

.metric-trend {
  @apply text-xs font-medium;
}

.metric-trend.positive {
  @apply text-green-400;
}

.metric-trend.negative {
  @apply text-red-400;
}

.charts-section {
  @apply space-y-4;
}

.chart-row {
  @apply grid grid-cols-2 gap-4;
}

.chart-card {
  @apply bg-slate-900/50 backdrop-blur border border-slate-800/60 rounded-xl p-6;
}

.chart-card.large {
  @apply col-span-1;
}

.chart-header {
  @apply flex justify-between items-center mb-4;
}

.chart-header h3 {
  @apply text-lg font-semibold text-white;
}

.chart-actions {
  @apply flex gap-2;
}

.chart-btn {
  @apply px-3 py-1 text-xs bg-slate-700 hover:bg-slate-600 text-slate-200 rounded border border-slate-600;
}

.chart-container {
  @apply relative h-64;
}

.chart-canvas {
  @apply w-full h-full;
}

.table-section {
  @apply bg-slate-900/50 backdrop-blur border border-slate-800/60 rounded-xl p-6;
}

.table-header {
  @apply flex justify-between items-center mb-4;
}

.table-header h3 {
  @apply text-lg font-semibold text-white;
}

.table-actions {
  @apply flex gap-3;
}

.search-input {
  @apply bg-slate-800/60 border border-slate-700 rounded-lg px-3 py-2 text-slate-200 placeholder-slate-400 focus:ring-2 focus:ring-cyan-500 focus:border-transparent;
}

.sort-select {
  @apply bg-slate-800/60 border border-slate-700 rounded-lg px-3 py-2 text-slate-200 focus:ring-2 focus:ring-cyan-500 focus:border-transparent;
}

.table-container {
  @apply overflow-x-auto;
}

.data-table {
  @apply w-full text-sm;
}

.data-table th {
  @apply text-left py-3 px-4 font-medium text-slate-300 border-b border-slate-700;
}

.data-table td {
  @apply py-3 px-4 border-b border-slate-800/50;
}

.table-row {
  @apply hover:bg-slate-800/30 transition-colors;
}

.asset-name {
  @apply font-medium text-white;
}

.score-cell {
  @apply flex items-center gap-3;
}

.score-value {
  @apply font-semibold text-white min-w-[3rem];
}

.score-bar {
  @apply flex-1 h-2 bg-slate-700 rounded-full overflow-hidden;
}

.score-fill {
  @apply h-full rounded-full transition-all duration-300;
}

.status-badge {
  @apply px-2 py-1 text-xs font-medium rounded-full;
}

.status-excellent {
  @apply bg-green-900/50 text-green-300 border border-green-700/50;
}

.status-good {
  @apply bg-blue-900/50 text-blue-300 border border-blue-700/50;
}

.status-fair {
  @apply bg-yellow-900/50 text-yellow-300 border border-yellow-700/50;
}

.status-poor {
  @apply bg-red-900/50 text-red-300 border border-red-700/50;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .filter-grid {
    @apply grid-cols-2;
  }
  
  .metrics-grid {
    @apply grid-cols-2;
  }
  
  .chart-row {
    @apply grid-cols-1;
  }
}

@media (max-width: 768px) {
  .header-content {
    @apply flex-col gap-4;
  }
  
  .filter-grid {
    @apply grid-cols-1;
  }
  
  .metrics-grid {
    @apply grid-cols-1;
  }
  
  .table-actions {
    @apply flex-col;
  }
}
</style>