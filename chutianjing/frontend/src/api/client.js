import axios from 'axios'

const apiClient = axios.create({
  baseURL: '/api',
  timeout: 15000,
})

export function setAuthToken(token) {
  if (token) {
    apiClient.defaults.headers.common['Authorization'] = `Basic ${token}`
  } else {
    delete apiClient.defaults.headers.common['Authorization']
  }
}

export default apiClient