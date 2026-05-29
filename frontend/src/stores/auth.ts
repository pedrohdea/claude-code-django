import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { api } from '@/api/client'

export const useAuthStore = defineStore('auth', () => {
  const access = ref<string | null>(localStorage.getItem('access'))
  const isAuthenticated = computed(() => !!access.value)

  async function login(email: string, password: string) {
    const { data } = await api.post('/auth/token/', { email, password })
    access.value = data.access
    localStorage.setItem('access', data.access)
    localStorage.setItem('refresh', data.refresh)
  }

  function logout() {
    access.value = null
    localStorage.removeItem('access')
    localStorage.removeItem('refresh')
  }

  return { access, isAuthenticated, login, logout }
})
