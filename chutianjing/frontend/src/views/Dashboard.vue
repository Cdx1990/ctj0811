<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import Chart from 'chart.js/auto'
import * as d3 from 'd3'

// 菜单数据
const menuData = [
  { code: '1', name: '全行资产质量信用风险预警', children: [
    { code: '1.1', name: '公司信用风险预警', children: [
      { code: '1.1.1', name: '大公司风险预警', children: [
        { code: '1.1.1.1', name: '机构风险预警', children: [] },
        { code: '1.1.1.2', name: '产品风险预警', children: [] },
        { code: '1.1.1.3', name: '行业风险预警', children: [] },
        { code: '1.1.1.4', name: '人员资产质量预警', children: [] },
      ] },
      { code: '1.1.2', name: '对公普惠风险预警', children: [
        { code: '1.1.2.1', name: '机构风险预警', children: [] },
        { code: '1.1.2.2', name: '产品风险预警', children: [] },
        { code: '1.1.2.3', name: '行业风险预警', children: [] },
        { code: '1.1.2.4', name: '人员资产质量预警', children: [] },
      ] },
    ] },
    { code: '1.2', name: '零售信用风险预警', children: [
      { code: '1.2.1', name: '消费金融风险预警', children: [
        { code: '1.2.1.1', name: '机构风险预警', children: [] },
        { code: '1.2.1.2', name: '产品风险预警', children: [] },
        { code: '1.2.1.3', name: '人员资产质量预警', children: [] },
      ] },
      { code: '1.2.2', name: '对私普惠风险预警', children: [
        { code: '1.2.2.1', name: '机构风险预警', children: [] },
        { code: '1.2.2.2', name: '产品风险预警', children: [] },
        { code: '1.2.2.3', name: '人员资产质量预警', children: [] },
      ] },
    ] },
    { code: '1.3', name: '银行卡风险预警', children: [
      { code: '1.3.1', name: '机构风险预警', children: [] },
      { code: '1.3.2', name: '人员资产质量预警', children: [] },
    ] },
  ] },
  { code: '2', name: '区域风险预警', children: [
    { code: '2.1', name: '区域经济风险预警', children: [
      { code: '2.1.1', name: '武汉市区域经济情况及预警指标', children: [] },
      { code: '2.1.2', name: '地市州区域经济情况及预警指标', children: [] },
    ] },
    { code: '2.2', name: '区域政策风险', children: [] },
    { code: '2.3', name: '区域风险特征', children: [
      { code: '2.3.1', name: '以制造业和中小企业为主，受经济周期影响较大', children: [] },
      { code: '2.3.2', name: '小微企业占比高，抗风险能力较弱', children: [] },
      { code: '2.3.3', name: '房地产相关贷款集中度较高', children: [] },
      { code: '2.3.4', name: '近期受产业结构调整影响，部分传统行业风险上升', children: [] },
    ] },
  ] },
  { code: '3', name: '行业风险预警', children: [
    { code: '3.1', name: '定量维度', children: [
      { code: '3.1.1', name: '资产质量', children: [] },
      { code: '3.1.2', name: '行业景气度', children: [] },
      { code: '3.1.3', name: '授信集中度风险', children: [] },
      { code: '3.1.4', name: '行业财务指标', children: [] },
    ] },
    { code: '3.2', name: '定性维度', children: [
      { code: '3.2.1', name: '行业竞争格局', children: [] },
      { code: '3.2.2', name: '宏观经济与政策环境', children: [] },
      { code: '3.2.3', name: '其他', children: [] },
    ] },
  ] },
  { code: '4', name: '集团风险预警', children: [
    { code: '4.1', name: '授信集中度风险预警', children: [] },
    { code: '4.2', name: '舆情风险预警', children: [] },
    { code: '4.3', name: '关联交易风险预警', children: [] },
    { code: '4.4', name: '其他预警', children: [] },
  ] },
  { code: '5', name: '金融市场信用风险预警', children: [
    { code: '5.1', name: '债券投资风险预警', children: [] },
    { code: '5.2', name: '衍生品风险预警', children: [] },
    { code: '5.3', name: '其他', children: [] },
  ] },
  { code: '6', name: '组合风险预警', children: [
    { code: '6.1', name: '信用组合风险', children: [] },
    { code: '6.2', name: '集中度风险', children: [] },
    { code: '6.3', name: '压力测试', children: [] },
    { code: '6.4', name: '经济资本计量', children: [] },
  ] },
  { code: '7', name: '生成式风险报告', children: [
    { code: '7.1', name: '日报', children: [] },
    { code: '7.2', name: '周报', children: [] },
    { code: '7.3', name: '月报', children: [] },
    { code: '7.4', name: '季报', children: [] },
    { code: '7.5', name: '年报', children: [] },
  ] },
  { code: '8', name: '意见建议词条', children: [] },
  { code: '9', name: '其他模块（待开发）', children: [] },
  { code: '10', name: '系统设置及用户管理', children: [
    { code: '10.1', name: '用户管理', children: [] },
    { code: '10.2', name: '角色管理', children: [] },
    { code: '10.3', name: '权限管理', children: [] },
    { code: '10.4', name: '系统参数设置', children: [] },
    { code: '10.5', name: '日志管理', children: [] },
  ] },
]

// 样例数据
const sampleData = {
  riskSummary: {
    totalAssets: 1258760000000,
    nonPerformingRate: 1.32,
    earlyWarningCount: 143,
    highRiskCount: 27,
    mediumRiskCount: 58,
    lowRiskCount: 58,
    riskTrend: [1.45, 1.42, 1.39, 1.36, 1.34, 1.32],
  },
  companyRisk: {
    largeCompany: { warningCount: 45, highRisk: 12, mediumRisk: 18, lowRisk: 15 },
    sme: { warningCount: 68, highRisk: 10, mediumRisk: 25, lowRisk: 33 },
    retail: { warningCount: 22, highRisk: 4, mediumRisk: 10, lowRisk: 8 },
    creditCard: { warningCount: 8, highRisk: 1, mediumRisk: 5, lowRisk: 2 },
  },
  riskEvents: [
    { id: 'EVT-2024-001', type: '公司风险', level: '高', company: '湖北某制造集团', date: '2024-12-15', description: '主要经营指标大幅下滑，现金流紧张' },
    { id: 'EVT-2024-002', type: '行业风险', level: '中', industry: '房地产开发', date: '2024-12-12', description: '政策收紧，多家房企融资困难' },
    { id: 'EVT-2024-003', type: '区域风险', level: '中', region: '荆州市', date: '2024-12-10', description: '地方政府债务压力上升' },
    { id: 'EVT-2024-004', type: '零售风险', level: '低', product: '个人消费贷', date: '2024-12-08', description: '逾期率小幅上升' },
    { id: 'EVT-2024-005', type: '集团风险', level: '高', group: '某控股集团', date: '2024-12-05', description: '关联交易异常，资金链紧张' },
  ],
}

const currentDate = ref('')
const currentTime = ref('')
const menuContainerRef = ref(null)

const trendCanvas = ref(null)
const distCanvas = ref(null)
const typeCanvas = ref(null)
let trendChart, distChart, typeChart

onMounted(() => {
  updateDateTime()
  const timer = setInterval(updateDateTime, 1000)
  ;(window)._dashboardTimer = timer

  generateMenu(menuData, menuContainerRef.value)
  initCharts()
  generateRiskEventsTable()
  initHeatmap()

  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  if (trendChart) trendChart.destroy()
  if (distChart) distChart.destroy()
  if (typeChart) typeChart.destroy()
  if ((window)._dashboardTimer) clearInterval((window)._dashboardTimer)
  window.removeEventListener('resize', handleResize)
})

function handleResize() {
  initHeatmap()
}

function updateDateTime() {
  const now = new Date()
  currentDate.value = now.toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })
  currentTime.value = now.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
}

function getIconForMenu(code) {
  const iconMap = {
    '1': 'fas fa-chart-line text-primary',
    '1.1': 'fas fa-building text-primary',
    '1.2': 'fas fa-users text-primary',
    '1.3': 'fas fa-credit-card text-primary',
    '2': 'fas fa-map-marker-alt text-secondary',
    '3': 'fas fa-industry text-secondary',
    '4': 'fas fa-sitemap text-secondary',
    '5': 'fas fa-chart-bar text-accent',
    '6': 'fas fa-layer-group text-accent',
    '7': 'fas fa-file-alt text-accent',
    '8': 'fas fa-comment-alt text-warning',
    '9': 'fas fa-cog text-warning',
    '10': 'fas fa-user-cog text-warning',
  }
  const codeParts = code.split('.')
  for (let i = codeParts.length; i > 0; i--) {
    const parentCode = codeParts.slice(0, i).join('.')
    if (iconMap[parentCode]) return iconMap[parentCode]
  }
  return 'fas fa-circle text-xs text-gray-500'
}

function generateMenu(items, container, level = 0) {
  const ul = document.createElement('ul')
  ul.className = `space-y-1 ${level > 0 ? 'pl-4' : ''}`
  items.forEach((item) => {
    const li = document.createElement('li')
    const menuLink = document.createElement('a')
    menuLink.className = `flex items-center justify-between w-full px-3 py-2 rounded-lg text-sm transition-all duration-200 ${level === 0 ? 'hover:bg-gray-800' : 'hover:bg-gray-800/50'} ${item.code === '1' ? 'menu-active' : ''}`
    const iconClass = getIconForMenu(item.code)

    const leftContent = document.createElement('div')
    leftContent.className = 'flex items-center'
    const iconSpan = document.createElement('span')
    iconSpan.className = `mr-3 ${iconClass}`
    const textSpan = document.createElement('span')
    textSpan.textContent = item.name
    textSpan.className = 'truncate'
    leftContent.appendChild(iconSpan)
    leftContent.appendChild(textSpan)
    menuLink.appendChild(leftContent)

    if (item.children && item.children.length > 0) {
      const toggleIcon = document.createElement('i')
      toggleIcon.className = 'fas fa-chevron-down text-xs text-gray-500 transition-transform duration-200'
      menuLink.appendChild(toggleIcon)
      menuLink.addEventListener('click', function (e) {
        e.preventDefault()
        const submenu = li.querySelector('ul')
        if (submenu) {
          submenu.classList.toggle('hidden')
          toggleIcon.classList.toggle('rotate-180')
        }
      })
    } else {
      menuLink.addEventListener('click', function (e) {
        e.preventDefault()
        document.querySelectorAll('.menu-active').forEach((el) => el.classList.remove('menu-active'))
        menuLink.classList.add('menu-active')
        showLoading()
        setTimeout(() => {
          hideLoading()
          showNotification(`已切换到: ${item.name}`)
        }, 500)
      })
    }

    li.appendChild(menuLink)

    if (item.children && item.children.length > 0) {
      const submenu = document.createElement('ul')
      submenu.className = `space-y-1 pl-4 mt-1 ${item.code === '1' ? '' : 'hidden'}`
      generateMenu(item.children, submenu, level + 1)
      li.appendChild(submenu)
      if (level === 0 && item.children.length > 0) {
        const firstChildLink = submenu.querySelector('a')
        if (firstChildLink && item.code === '1') {
          firstChildLink.classList.add('menu-active')
        }
      }
    }

    ul.appendChild(li)
  })
  container.appendChild(ul)
}

function initCharts() {
  // 风险趋势
  if (trendChart) trendChart.destroy()
  const ctxTrend = trendCanvas.value.getContext('2d')
  trendChart = new Chart(ctxTrend, {
    type: 'line',
    data: {
      labels: ['1月', '2月', '3月', '4月', '5月', '6月'],
      datasets: [
        {
          label: '不良贷款率(%)',
          data: sampleData.riskSummary.riskTrend,
          borderColor: '#00d4ff',
          backgroundColor: 'rgba(0, 212, 255, 0.1)',
          borderWidth: 2,
          fill: true,
          tension: 0.4,
          pointBackgroundColor: '#00d4ff',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
        },
        {
          label: '关注类贷款率(%)',
          data: [2.56, 2.52, 2.49, 2.47, 2.46, 2.45],
          borderColor: '#7e22ce',
          backgroundColor: 'rgba(126, 34, 206, 0.1)',
          borderWidth: 2,
          fill: true,
          tension: 0.4,
          pointBackgroundColor: '#7e22ce',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: { color: '#f8fafc', usePointStyle: true, padding: 20 },
        },
        tooltip: {
          mode: 'index',
          intersect: false,
          backgroundColor: 'rgba(15, 23, 42, 0.9)',
          borderColor: 'rgba(0, 212, 255, 0.3)',
          borderWidth: 1,
          padding: 12,
          titleColor: '#f8fafc',
          bodyColor: '#f8fafc',
          callbacks: { label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y}%` },
        },
      },
      scales: {
        x: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } },
        y: {
          grid: { color: 'rgba(255,255,255,0.05)' },
          ticks: { color: '#94a3b8', callback: (v) => v + '%' },
          beginAtZero: true,
        },
      },
      interaction: { mode: 'nearest', axis: 'x', intersect: false },
      elements: { line: { tension: 0.4 } },
    },
  })

  // 风险分布
  if (distChart) distChart.destroy()
  const ctxDist = distCanvas.value.getContext('2d')
  distChart = new Chart(ctxDist, {
    type: 'doughnut',
    data: {
      labels: ['高风险', '中风险', '低风险'],
      datasets: [
        {
          data: [
            sampleData.riskSummary.highRiskCount,
            sampleData.riskSummary.mediumRiskCount,
            sampleData.riskSummary.lowRiskCount,
          ],
          backgroundColor: ['#ef4444', '#f59e0b', '#10b981'],
          borderColor: ['#dc2626', '#d97706', '#059669'],
          borderWidth: 2,
          hoverOffset: 10,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'bottom', labels: { color: '#f8fafc', usePointStyle: true, padding: 20 } },
        tooltip: {
          backgroundColor: 'rgba(15, 23, 42, 0.9)',
          borderColor: 'rgba(0, 212, 255, 0.3)',
          borderWidth: 1,
          padding: 12,
          titleColor: '#f8fafc',
          bodyColor: '#f8fafc',
          callbacks: {
            label: (ctx) => {
              const value = ctx.parsed
              const total = ctx.dataset.data.reduce((a, b) => a + b, 0)
              const pct = ((value / total) * 100).toFixed(1)
              return `${ctx.label}: ${value} (${pct}%)`
            },
          },
        },
      },
      cutout: '65%',
    },
  })

  // 风险类型
  if (typeChart) typeChart.destroy()
  const ctxType = typeCanvas.value.getContext('2d')
  typeChart = new Chart(ctxType, {
    type: 'bar',
    data: {
      labels: ['大公司风险', '对公普惠风险', '零售风险', '银行卡风险'],
      datasets: [
        {
          label: '高风险',
          data: [
            sampleData.companyRisk.largeCompany.highRisk,
            sampleData.companyRisk.sme.highRisk,
            sampleData.companyRisk.retail.highRisk,
            sampleData.companyRisk.creditCard.highRisk,
          ],
          backgroundColor: '#ef4444',
          borderRadius: 4,
          borderSkipped: false,
        },
        {
          label: '中风险',
          data: [
            sampleData.companyRisk.largeCompany.mediumRisk,
            sampleData.companyRisk.sme.mediumRisk,
            sampleData.companyRisk.retail.mediumRisk,
            sampleData.companyRisk.creditCard.mediumRisk,
          ],
          backgroundColor: '#f59e0b',
          borderRadius: 4,
          borderSkipped: false,
        },
        {
          label: '低风险',
          data: [
            sampleData.companyRisk.largeCompany.lowRisk,
            sampleData.companyRisk.sme.lowRisk,
            sampleData.companyRisk.retail.lowRisk,
            sampleData.companyRisk.creditCard.lowRisk,
          ],
          backgroundColor: '#10b981',
          borderRadius: 4,
          borderSkipped: false,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'top', labels: { color: '#f8fafc', usePointStyle: true, padding: 20 } },
        tooltip: {
          backgroundColor: 'rgba(15,23,42,0.9)',
          borderColor: 'rgba(0,212,255,0.3)',
          borderWidth: 1,
          padding: 12,
          titleColor: '#f8fafc',
          bodyColor: '#f8fafc',
        },
      },
      scales: {
        x: { stacked: true, grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } },
        y: { stacked: true, grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8', beginAtZero: true } },
      },
    },
  })
}

function generateRiskEventsTable() {
  const tbody = document.getElementById('riskEventsTable')
  if (!tbody) return
  tbody.innerHTML = ''
  sampleData.riskEvents.forEach((event) => {
    const row = document.createElement('tr')
    row.className = 'border-b border-gray-800 hover:bg-gray-800/30 transition-colors'
    const levelColor = event.level === '高' ? 'text-danger bg-danger/20' : event.level === '中' ? 'text-warning bg-warning/20' : 'text-success bg-success/20'
    row.innerHTML = `
      <td class="py-3 px-4 font-mono text-xs">${event.id}</td>
      <td class="py-3 px-4">${event.type}</td>
      <td class="py-3 px-4"><span class="px-2 py-1 rounded text-xs ${levelColor}">${event.level}</span></td>
      <td class="py-3 px-4">${event.company || event.industry || event.region || event.product || event.group}</td>
      <td class="py-3 px-4 text-sm">${event.date}</td>
      <td class="py-3 px-4 text-sm text-gray-300">${event.description}</td>
      <td class="py-3 px-4">
        <button class="text-secondary hover:text-white transition-colors mr-3"><i class="fas fa-eye"></i></button>
        <button class="text-gray-400 hover:text-white transition-colors"><i class="fas fa-ellipsis-v"></i></button>
      </td>`
    tbody.appendChild(row)
  })
}

function initHeatmap() {
  const container = d3.select('#regionalHeatmap')
  if (!container.node()) return
  const margin = { top: 20, right: 30, bottom: 40, left: 60 }
  const width = container.node().getBoundingClientRect().width - margin.left - margin.right
  const height = 384 - margin.top - margin.bottom
  container.selectAll('*').remove()

  const svg = container
    .append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const regions = [
    { name: '武汉市', risk: 75, badLoan: 1.25, warningCount: 32 },
    { name: '襄阳市', risk: 58, badLoan: 0.98, warningCount: 15 },
    { name: '宜昌市', risk: 67, badLoan: 1.32, warningCount: 18 },
    { name: '荆州市', risk: 82, badLoan: 1.87, warningCount: 22 },
    { name: '黄冈市', risk: 65, badLoan: 1.45, warningCount: 16 },
    { name: '孝感市', risk: 52, badLoan: 1.12, warningCount: 14 },
    { name: '荆门市', risk: 61, badLoan: 1.28, warningCount: 17 },
    { name: '十堰市', risk: 55, badLoan: 1.05, warningCount: 13 },
    { name: '咸宁市', risk: 48, badLoan: 0.92, warningCount: 11 },
    { name: '随州市', risk: 53, badLoan: 1.08, warningCount: 12 },
  ]

  const xScale = d3.scaleLinear().domain([0, 100]).range([0, width])
  const yScale = d3.scaleBand().domain(regions.map((d) => d.name)).range([0, height]).padding(0.1)
  const colorScale = d3.scaleSequential(d3.interpolateReds).domain([0, 100])

  g.selectAll('.bar')
    .data(regions)
    .enter()
    .append('rect')
    .attr('class', 'bar')
    .attr('y', (d) => yScale(d.name))
    .attr('height', yScale.bandwidth())
    .attr('x', 0)
    .attr('width', (d) => xScale(d.risk))
    .attr('fill', (d) => colorScale(d.risk))
    .attr('rx', 4)
    .attr('opacity', 0.8)
    .on('mouseover', function (event, d) {
      d3.select(this).attr('opacity', 1)
      const tooltip = d3
        .select('body')
        .append('div')
        .attr('class', 'tooltip')
        .style('position', 'absolute')
        .style('background', 'rgba(15, 23, 42, 0.9)')
        .style('border', '1px solid rgba(0, 212, 255, 0.3)')
        .style('border-radius', '4px')
        .style('padding', '8px')
        .style('color', '#f8fafc')
        .style('font-size', '12px')
        .style('pointer-events', 'none')
        .style('z-index', '1000')
        .html(`
          <div class="font-semibold">${d.name}</div>
          <div class="mt-1">风险指数: ${d.risk}</div>
          <div>不良贷款率: ${d.badLoan}%</div>
          <div>预警数量: ${d.warningCount}</div>
        `)
        .style('left', event.pageX + 10 + 'px')
        .style('top', event.pageY - 10 + 'px')
    })
    .on('mouseout', function () {
      d3.select(this).attr('opacity', 0.8)
      d3.selectAll('.tooltip').remove()
    })

  g.append('g')
    .call(d3.axisLeft(yScale))
    .selectAll('text')
    .style('fill', '#94a3b8')
    .style('font-size', '12px')

  g.append('g')
    .attr('transform', `translate(0,${height})`)
    .call(d3.axisBottom(xScale))
    .selectAll('text')
    .style('fill', '#94a3b8')
    .style('font-size', '12px')

  g.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('y', 0 - margin.left)
    .attr('x', 0 - height / 2)
    .attr('dy', '1em')
    .style('text-anchor', 'middle')
    .style('fill', '#94a3b8')
    .style('font-size', '12px')
    .text('区域')

  g.append('text')
    .attr('transform', `translate(${width / 2}, ${height + margin.bottom - 5})`)
    .style('text-anchor', 'middle')
    .style('fill', '#94a3b8')
    .style('font-size', '12px')
    .text('风险指数')
}

function showLoading() {
  const id = 'loadingOverlay'
  if (document.getElementById(id)) return
  const overlay = document.createElement('div')
  overlay.id = id
  overlay.className = 'fixed inset-0 bg-dark/80 flex items-center justify-center z-50'
  overlay.innerHTML = `
    <div class="text-center">
      <div class="w-16 h-16 border-4 border-secondary border-t-transparent rounded-full animate-spin mb-4"></div>
      <p class="text-light">加载中...</p>
    </div>`
  document.body.appendChild(overlay)
}

function hideLoading() {
  const overlay = document.getElementById('loadingOverlay')
  if (overlay) overlay.remove()
}

function showNotification(message) {
  const notification = document.createElement('div')
  notification.className = 'fixed bottom-4 right-4 bg-dark border border-secondary text-light px-6 py-3 rounded-lg shadow-lg shadow-secondary/20 z-40 transform translate-y-0 opacity-0 transition-all duration-300'
  notification.innerHTML = `<div class="flex items-center"><i class="fas fa-info-circle text-secondary mr-3"></i><span>${message}</span></div>`
  document.body.appendChild(notification)
  setTimeout(() => {
    notification.classList.remove('translate-y-0', 'opacity-0')
    notification.classList.add('-translate-y-2', 'opacity-100')
  }, 10)
  setTimeout(() => {
    notification.classList.remove('-translate-y-2', 'opacity-100')
    notification.classList.add('translate-y-0', 'opacity-0')
    setTimeout(() => notification.remove(), 300)
  }, 3000)
}
</script>

<template>
  <div class="bg-dark text-light overflow-hidden h-screen flex flex-col">
    <header class="bg-darker border-b border-gray-800 py-3 px-4 flex items-center justify-between relative z-10">
      <div class="flex items-center space-x-4">
        <div class="text-2xl font-bold bg-gradient-to-r from-secondary to-accent bg-clip-text text-transparent flex items-center">
          <i class="fas fa-shield-alt mr-3 text-secondary animate-glow"></i>
          <span>楚天镜智能风控系统</span>
        </div>
      </div>
      <div class="flex items-center space-x-6">
        <div class="relative">
          <div class="flex items-center space-x-2 text-sm">
            <i class="fas fa-calendar-alt text-secondary"></i>
            <span>{{ currentDate }}</span>
          </div>
        </div>
        <div class="relative">
          <div class="flex items-center space-x-2 text-sm">
            <i class="fas fa-clock text-secondary"></i>
            <span>{{ currentTime }}</span>
          </div>
        </div>
        <div class="relative">
          <button class="flex items-center space-x-2 bg-gray-800 hover:bg-gray-700 rounded-full px-4 py-2 transition-all duration-300">
            <div class="w-8 h-8 rounded-full bg-gradient-to-r from-primary to-secondary flex items-center justify-center">
              <i class="fas fa-user text-xs"></i>
            </div>
            <span class="text-sm">管理员</span>
            <i class="fas fa-chevron-down text-xs text-gray-400"></i>
          </button>
        </div>
      </div>
    </header>

    <div class="flex flex-1 overflow-hidden">
      <aside id="sidebar" class="w-64 bg-darker border-r border-gray-800 flex-shrink-0 overflow-y-auto scrollbar-hidden transition-all duration-300">
        <div class="p-4">
          <div class="relative">
            <input type="text" placeholder="搜索菜单..." class="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 pl-10 text-sm focus:outline-none focus:ring-2 focus:ring-secondary" />
            <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
          </div>
        </div>
        <nav ref="menuContainerRef" id="menuContainer" class="p-2"></nav>
      </aside>

      <main class="flex-1 overflow-y-auto bg-grid relative">
        <div class="p-6 max-w-full">
          <div class="mb-8">
            <h1 class="text-[clamp(1.5rem,3vw,2.5rem)] font-bold mb-2">
              <span class="bg-gradient-to-r from-secondary to-accent bg-clip-text text-transparent">风险监控中心</span>
            </h1>
            <p class="text-gray-400 text-lg">实时监控全行信用风险状况，智能预警潜在风险点</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="glass-effect rounded-xl p-6 hover:shadow-lg hover:shadow-secondary/10 transition-all duration-300 transform hover:-translate-y-1">
              <div class="flex justify-between items-start">
                <div>
                  <p class="text-gray-400 text-sm mb-1">总资产规模</p>
                  <h3 class="text-2xl font-bold">1.26万亿</h3>
                  <p class="text-success text-sm mt-2 flex items-center"><i class="fas fa-arrow-up mr-1"></i> 2.3% <span class="text-gray-500 ml-1">较上月</span></p>
                </div>
                <div class="w-12 h-12 bg-primary/20 rounded-lg flex items-center justify-center">
                  <i class="fas fa-coins text-primary text-xl"></i>
                </div>
              </div>
            </div>
            <div class="glass-effect rounded-xl p-6 hover:shadow-lg hover:shadow-secondary/10 transition-all duration-300 transform hover:-translate-y-1">
              <div class="flex justify-between items-start">
                <div>
                  <p class="text-gray-400 text-sm mb-1">不良贷款率</p>
                  <h3 class="text-2xl font-bold">1.32%</h3>
                  <p class="text-success text-sm mt-2 flex items-center"><i class="fas fa-arrow-down mr-1"></i> 0.05% <span class="text-gray-500 ml-1">较上月</span></p>
                </div>
                <div class="w-12 h-12 bg-warning/20 rounded-lg flex items-center justify-center">
                  <i class="fas fa-exclamation-triangle text-warning text-xl"></i>
                </div>
              </div>
            </div>
            <div class="glass-effect rounded-xl p-6 hover:shadow-lg hover:shadow-secondary/10 transition-all duration-300 transform hover:-translate-y-1">
              <div class="flex justify-between items-start">
                <div>
                  <p class="text-gray-400 text-sm mb-1">风险预警总数</p>
                  <h3 class="text-2xl font-bold">143</h3>
                  <p class="text-danger text-sm mt-2 flex items-center"><i class="fas fa-arrow-up mr-1"></i> 8.2% <span class="text-gray-500 ml-1">较上月</span></p>
                </div>
                <div class="w-12 h-12 bg-danger/20 rounded-lg flex items-center justify-center">
                  <i class="fas fa-bell text-danger text-xl"></i>
                </div>
              </div>
            </div>
            <div class="glass-effect rounded-xl p-6 hover:shadow-lg hover:shadow-secondary/10 transition-all duration-300 transform hover:-translate-y-1">
              <div class="flex justify-between items-start">
                <div>
                  <p class="text-gray-400 text-sm mb-1">高风险客户</p>
                  <h3 class="text-2xl font-bold">27</h3>
                  <p class="text-success text-sm mt-2 flex items-center"><i class="fas fa-arrow-down mr-1"></i> 3.6% <span class="text-gray-500 ml-1">较上月</span></p>
                </div>
                <div class="w-12 h-12 bg-accent/20 rounded-lg flex items-center justify-center">
                  <i class="fas fa-user-times text-accent text-xl"></i>
                </div>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            <div class="glass-effect rounded-xl p-6 lg:col-span-2">
              <div class="flex justify-between items-center mb-6">
                <h3 class="text-lg font-semibold">风险指标趋势</h3>
                <div class="flex space-x-2">
                  <button class="px-3 py-1 text-xs bg-gray-800 rounded-md hover:bg-gray-700 transition-colors">月度</button>
                  <button class="px-3 py-1 text-xs bg-secondary text-dark rounded-md hover:bg-secondary/80 transition-colors">季度</button>
                  <button class="px-3 py-1 text-xs bg-gray-800 rounded-md hover:bg-gray-700 transition-colors">年度</button>
                </div>
              </div>
              <div class="h-80"><canvas ref="trendCanvas"></canvas></div>
            </div>
            <div class="glass-effect rounded-xl p-6">
              <div class="flex justify-between items-center mb-6">
                <h3 class="text-lg font-semibold">风险等级分布</h3>
                <button class="text-gray-400 hover:text-white transition-colors"><i class="fas fa-ellipsis-v"></i></button>
              </div>
              <div class="h-80 flex items-center justify-center"><canvas ref="distCanvas"></canvas></div>
            </div>
          </div>

          <div class="glass-effect rounded-xl p-6 mb-8">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-semibold">风险类型分析</h3>
              <div class="flex space-x-4">
                <div class="flex items-center space-x-2"><span class="w-3 h-3 bg-primary rounded-full"></span><span class="text-xs text-gray-400">大公司风险</span></div>
                <div class="flex items-center space-x-2"><span class="w-3 h-3 bg-secondary rounded-full"></span><span class="text-xs text-gray-400">对公普惠风险</span></div>
                <div class="flex items-center space-x-2"><span class="w-3 h-3 bg-accent rounded-full"></span><span class="text-xs text-gray-400">零售风险</span></div>
                <div class="flex items-center space-x-2"><span class="w-3 h-3 bg-warning rounded-full"></span><span class="text-xs text-gray-400">银行卡风险</span></div>
              </div>
            </div>
            <div class="h-80"><canvas ref="typeCanvas"></canvas></div>
          </div>

          <div class="glass-effect rounded-xl p-6 mb-8">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-semibold">区域风险热力图</h3>
              <button class="text-sm bg-gray-800 hover:bg-gray-700 px-3 py-1 rounded-md transition-colors"><i class="fas fa-download mr-1"></i> 导出数据</button>
            </div>
            <div id="regionalHeatmap" class="h-96 border border-gray-800 rounded-lg"></div>
          </div>

          <div class="glass-effect rounded-xl p-6 mb-8">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-semibold">最新风险事件</h3>
              <button class="text-sm bg-secondary text-dark px-3 py-1 rounded-md hover:bg-secondary/80 transition-colors">查看全部</button>
            </div>
            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead>
                  <tr class="border-b border-gray-800">
                    <th class="text-left py-3 px-4 font-medium text-gray-400">事件ID</th>
                    <th class="text-left py-3 px-4 font-medium text-gray-400">风险类型</th>
                    <th class="text-left py-3 px-4 font-medium text-gray-400">风险等级</th>
                    <th class="text-left py-3 px-4 font-medium text-gray-400">涉及对象</th>
                    <th class="text-left py-3 px-4 font-medium text-gray-400">发生日期</th>
                    <th class="text-left py-3 px-4 font-medium text-gray-400">描述</th>
                    <th class="text-left py-3 px-4 font-medium text-gray-400">操作</th>
                  </tr>
                </thead>
                <tbody id="riskEventsTable"></tbody>
              </table>
            </div>
          </div>
        </div>
      </main>

      <aside class="w-72 bg-darker border-l border-gray-800 flex-shrink-0 flex flex-col">
        <div class="p-6 border-b border-gray-800">
          <h3 class="text-lg font-semibold mb-4">风险指标概览</h3>
          <div class="space-y-4">
            <div>
              <div class="flex justify-between items-center mb-1"><span class="text-sm text-gray-400">不良贷款率</span><span class="text-sm font-medium">1.32%</span></div>
              <div class="w-full bg-gray-800 rounded-full h-2"><div class="bg-warning h-2 rounded-full" style="width: 35%"></div></div>
            </div>
            <div>
              <div class="flex justify-between items-center mb-1"><span class="text-sm text-gray-400">关注类贷款占比</span><span class="text-sm font-medium">2.45%</span></div>
              <div class="w-full bg-gray-800 rounded-full h-2"><div class="bg-info h-2 rounded-full" style="width: 45%"></div></div>
            </div>
            <div>
              <div class="flex justify-between items-center mb-1"><span class="text-sm text-gray-400">拨备覆盖率</span><span class="text-sm font-medium">215.3%</span></div>
              <div class="w-full bg-gray-800 rounded-full h-2"><div class="bg-success h-2 rounded-full" style="width: 75%"></div></div>
            </div>
            <div>
              <div class="flex justify-between items-center mb-1"><span class="text-sm text-gray-400">单一集团客户授信集中度</span><span class="text-sm font-medium">12.8%</span></div>
              <div class="w-full bg-gray-800 rounded-full h-2"><div class="bg-primary h-2 rounded-full" style="width: 60%"></div></div>
            </div>
          </div>
        </div>
        <div class="p-6 border-b border-gray-800 flex-1 overflow-y-auto">
          <h3 class="text-lg font-semibold mb-4">行业风险排名</h3>
          <div class="space-y-4">
            <div class="flex items-center justify-between p-3 bg-danger/10 rounded-lg border border-danger/20">
              <div class="flex items-center">
                <div class="w-8 h-8 bg-danger/20 rounded-full flex items-center justify-center mr-3"><i class="fas fa-industry text-danger text-sm"></i></div>
                <div>
                  <p class="text-sm font-medium">房地产开发</p>
                  <p class="text-xs text-gray-400">风险指数: 87</p>
                </div>
              </div>
              <span class="px-2 py-1 bg-danger/20 text-danger text-xs rounded">高风险</span>
            </div>
            <div class="flex items-center justify-between p-3 bg-danger/10 rounded-lg border border-danger/20">
              <div class="flex items-center">
                <div class="w-8 h-8 bg-danger/20 rounded-full flex items-center justify-center mr-3"><i class="fas fa-cogs text-danger text-sm"></i></div>
                <div>
                  <p class="text-sm font-medium">传统制造业</p>
                  <p class="text-xs text-gray-400">风险指数: 82</p>
                </div>
              </div>
              <span class="px-2 py-1 bg-danger/20 text-danger text-xs rounded">高风险</span>
            </div>
            <div class="flex items-center justify-between p-3 bg-warning/10 rounded-lg border border-warning/20">
              <div class="flex items-center">
                <div class="w-8 h-8 bg-warning/20 rounded-full flex items-center justify-center mr-3"><i class="fas fa-truck text-warning text-sm"></i></div>
                <div>
                  <p class="text-sm font-medium">批发零售业</p>
                  <p class="text-xs text-gray-400">风险指数: 65</p>
                </div>
              </div>
              <span class="px-2 py-1 bg-warning/20 text-warning text-xs rounded">中风险</span>
            </div>
            <div class="flex items-center justify-between p-3 bg-warning/10 rounded-lg border border-warning/20">
              <div class="flex items-center">
                <div class="w-8 h-8 bg-warning/20 rounded-full flex items-center justify-center mr-3"><i class="fas fa-building text-warning text-sm"></i></div>
                <div>
                  <p class="text-sm font-medium">建筑业</p>
                  <p class="text-xs text-gray-400">风险指数: 62</p>
                </div>
              </div>
              <span class="px-2 py-1 bg-warning/20 text-warning text-xs rounded">中风险</span>
            </div>
            <div class="flex items-center justify-between p-3 bg-success/10 rounded-lg border border-success/20">
              <div class="flex items-center">
                <div class="w-8 h-8 bg-success/20 rounded-full flex items-center justify-center mr-3"><i class="fas fa-laptop text-success text-sm"></i></div>
                <div>
                  <p class="text-sm font-medium">信息技术</p>
                  <p class="text-xs text-gray-400">风险指数: 45</p>
                </div>
              </div>
              <span class="px-2 py-1 bg-success/20 text-success text-xs rounded">低风险</span>
            </div>
          </div>
        </div>
        <div class="p-4 bg-gray-900 border-t border-gray-800">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-2">
              <span class="w-2 h-2 bg-success rounded-full animate-pulse"></span>
              <span class="text-xs text-gray-400">系统运行正常</span>
            </div>
            <span class="text-xs text-gray-500">最后更新: 2分钟前</span>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<style scoped>
/* 颜色与特效（以普通 CSS 实现，无需 Tailwind 扩展） */
.bg-dark { background-color: #0f172a; }
.bg-darker { background-color: #0b1220; }
.text-light { color: #f8fafc; }

.text-shadow { text-shadow: 0 0 10px rgba(0, 212, 255, 0.7); }
.bg-grid {
  background-image: linear-gradient(rgba(255, 255, 255, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
  background-size: 20px 20px;
}
.scrollbar-hidden::-webkit-scrollbar { display: none; }
.scrollbar-hidden { -ms-overflow-style: none; scrollbar-width: none; }
.glass-effect {
  backdrop-filter: blur(10px);
  background-color: rgba(15, 23, 42, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.1);
}
.menu-active { background: linear-gradient(90deg, rgba(0, 212, 255, 0.2) 0%, rgba(126, 34, 206, 0.2) 100%); border-left: 3px solid #00d4ff; }

/* 主题色 */
.text-primary { color: #0070f3; }
.bg-primary\/20 { background-color: rgba(0, 112, 243, 0.2); }
.text-secondary { color: #00d4ff; }
.bg-secondary { background-color: #00d4ff; }
.text-accent { color: #7e22ce; }
.bg-accent\/20 { background-color: rgba(126, 34, 206, 0.2); }
.text-warning { color: #f59e0b; }
.bg-warning\/20 { background-color: rgba(245, 158, 11, 0.2); }
.text-danger { color: #ef4444; }
.bg-danger\/20 { background-color: rgba(239, 68, 68, 0.2); }
.text-success { color: #10b981; }
.bg-success\/20 { background-color: rgba(16, 185, 129, 0.2); }
.text-info { color: #3b82f6; }
.bg-info { background-color: #3b82f6; }
.text-dark { color: #0f172a; }

/* 动画 */
@keyframes glow { 0% { box-shadow: 0 0 5px rgba(0, 212, 255, 0.5); } 100% { box-shadow: 0 0 20px rgba(0, 212, 255, 0.8), 0 0 30px rgba(0, 212, 255, 0.4); } }
.animate-glow { animation: glow 2s ease-in-out infinite alternate; }
</style>