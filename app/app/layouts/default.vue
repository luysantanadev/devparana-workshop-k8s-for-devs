<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const route = useRoute()
const open = ref(false)

const links = [[
  {
    label: 'Todos',
    icon: 'i-lucide-check-square',
    to: '/todos',
    onSelect: () => { open.value = false },
  },
  {
    label: 'Users',
    icon: 'i-lucide-users',
    to: '/users',
    onSelect: () => { open.value = false },
  },
  {
    label: 'Categories',
    icon: 'i-lucide-tag',
    to: '/categories',
    onSelect: () => { open.value = false },
  },
]] satisfies NavigationMenuItem[][]

const groups = computed(() => [
  {
    id: 'links',
    label: 'Go to',
    items: links.flat(),
  },
])
</script>

<template>
  <UDashboardGroup unit="rem">
    <UDashboardSidebar
      id="default"
      v-model:open="open"
      collapsible
      resizable
      class="bg-elevated/25"
      :ui="{ footer: 'lg:border-t lg:border-default' }"
    >
      <template #header>
        <div class="flex items-center gap-2 px-2 py-1">
          <UIcon name="i-lucide-layout-dashboard" class="size-6 text-primary shrink-0" />
          <span class="font-semibold text-highlighted truncate">K8s Admin</span>
        </div>
      </template>

      <template #default="{ collapsed }">
        <UDashboardSearchButton
          :collapsed="collapsed"
          class="bg-transparent ring-default"
        />
        <UNavigationMenu
          :collapsed="collapsed"
          :items="links[0]"
          orientation="vertical"
          tooltip
          popover
        />
      </template>

      <template #footer="{ collapsed }">
        <AppUserMenu :collapsed="collapsed" />
      </template>
    </UDashboardSidebar>

    <UDashboardSearch :groups="groups" />

    <slot />
  </UDashboardGroup>
</template>
