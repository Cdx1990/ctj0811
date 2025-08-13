import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', redirect: '/risk/overview' },
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

export default router