import { createRouter, createWebHistory } from 'vue-router'
import axios from 'axios'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', component: () => import('../views/Login.vue'), meta: { fullPage: true, public: true } },
  { path: '/dashboard', component: () => import('../views/Dashboard.vue'), meta: { fullPage: true } },
  {
    path: '/risk',
    component: () => import('../views/RiskLayout.vue'),
    children: [
      { path: 'overview', component: () => import('../views/Overview.vue') },
      { path: 'corporate', component: () => import('../views/Corporate.vue') },
      { path: 'retail', component: () => import('../views/Retail.vue') },
      { path: 'cards', component: () => import('../views/Cards.vue') },
      { path: 'region', component: () => import('../views/Region.vue') },
      { path: 'industry', component: () => import('../views/Industry.vue') },
      { path: 'group', component: () => import('../views/Group.vue') },
      { path: 'market', component: () => import('../views/Market.vue') },
      { path: 'portfolio', component: () => import('../views/Portfolio.vue') },
      { path: 'gen-report', component: () => import('../views/GenReport.vue') },
      { path: 'settings', component: () => import('../views/Settings.vue') },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to) => {
  if (to.meta.public) return true
  const token = localStorage.getItem('basicAuth') || sessionStorage.getItem('basicAuth')
  if (!token) return '/login'
  // 可选：轻量校验令牌有效性
  axios.defaults.headers.common['Authorization'] = token
  return true
})

export default router