<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useItemsStore } from '@/stores/items'

const store = useItemsStore()
const newTitle = ref('')

onMounted(store.fetchItems)

async function add() {
  if (!newTitle.value.trim()) return
  await store.addItem(newTitle.value)
  newTitle.value = ''
}
</script>

<template>
  <section>
    <h2>Items</h2>
    <input v-model="newTitle" placeholder="novo item" @keyup.enter="add" />
    <button @click="add">Adicionar</button>
    <ul>
      <li v-for="item in store.items" :key="item.id">
        <input type="checkbox" :checked="item.done" @change="store.toggle(item)" />
        {{ item.title }}
      </li>
    </ul>
  </section>
</template>
