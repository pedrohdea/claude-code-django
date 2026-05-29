import { defineStore } from 'pinia'
import { ref } from 'vue'
import { api } from '@/api/client'

export interface Item {
  id: number
  title: string
  done: boolean
  created_at: string
}

export const useItemsStore = defineStore('items', () => {
  const items = ref<Item[]>([])

  async function fetchItems() {
    const { data } = await api.get('/items/')
    items.value = data.results
  }

  async function addItem(title: string) {
    const { data } = await api.post('/items/', { title })
    items.value.unshift(data)
  }

  async function toggle(item: Item) {
    const { data } = await api.patch(`/items/${item.id}/`, { done: !item.done })
    Object.assign(item, data)
  }

  return { items, fetchItems, addItem, toggle }
})
