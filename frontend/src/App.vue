<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
</script>

<template>
  <nav>
    <RouterLink to="/">Home</RouterLink>
    <RouterLink v-if="!auth.isAuthenticated" to="/login">Login</RouterLink>
    <RouterLink v-else to="/items">Items</RouterLink>
    <button v-if="auth.isAuthenticated" @click="auth.logout">Logout</button>
  </nav>
  <main><RouterView /></main>
</template>
