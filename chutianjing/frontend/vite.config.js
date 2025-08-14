import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

const gatewayTarget = process.env.API_GATEWAY_URL || 'http://localhost:8080'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: true,
    port: 5173,
    proxy: {
      '/api': {
        target: gatewayTarget,
        changeOrigin: true,
      },
    },
  },
})
