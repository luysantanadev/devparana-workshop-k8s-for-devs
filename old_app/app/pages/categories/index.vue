<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'

definePageMeta({ title: 'Categories' })

type Category = { id: number; name: string }

const toast = useToast()
const UDropdownMenu = resolveComponent('UDropdownMenu')
const UButton = resolveComponent('UButton')

const { data: categories, refresh } = await useFetch<Category[]>('/api/categories')

async function remove(id: number) {
  await $fetch(`/api/categories/${id}`, { method: 'DELETE' })
  toast.add({ title: 'Category deleted', icon: 'i-lucide-trash-2', color: 'error' })
  await refresh()
}

const columns: TableColumn<Category>[] = [
  { accessorKey: 'id', header: 'ID' },
  { accessorKey: 'name', header: 'Name' },
  {
    id: 'actions',
    header: '',
    cell: ({ row }) =>
      h(UDropdownMenu, {
        items: [[
          { label: 'Edit', icon: 'i-lucide-pencil', to: `/categories/${row.original.id}/edit` },
          { label: 'Delete', icon: 'i-lucide-trash-2', color: 'error',
            onSelect: () => remove(row.original.id) },
        ]],
        content: { align: 'end' },
      }, () => h(UButton, { icon: 'i-lucide-ellipsis-vertical', color: 'neutral', variant: 'ghost', size: 'sm' })),
  },
]
</script>

<template>
  <UDashboardPanel>
    <template #header>
      <UDashboardNavbar title="Categories">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>

        <template #right>
          <UButton icon="i-lucide-plus" to="/categories/new">New Category</UButton>
        </template>
      </UDashboardNavbar>
    </template>

    <UTable :data="categories ?? []" :columns="columns" class="w-full" />
  </UDashboardPanel>
</template>
