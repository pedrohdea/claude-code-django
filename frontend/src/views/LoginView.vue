<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const email = ref('')
const password = ref('')
const error = ref('')
const auth = useAuthStore()
const router = useRouter()

async function submit() {
  try {
    await auth.login(email.value, password.value)
    router.push('/items')
  } catch {
    error.value = 'Credenciais inválidas'
  }
}
</script>

<template>
  <section>
    <h2>Login</h2>
    <input v-model="email" type="email" placeholder="email" />
    <input v-model="password" type="password" placeholder="senha" />
    <button @click="submit">Entrar</button>
    <p v-if="error">{{ error }}</p>
  </section>
</template>
