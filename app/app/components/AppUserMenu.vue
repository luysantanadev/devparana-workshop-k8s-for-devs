<script setup lang="ts">
defineProps<{ collapsed?: boolean }>()

const colorMode = useColorMode()

const items = computed(() => [
  [{
    label: 'Appearance',
    icon: 'i-lucide-sun-moon',
    children: [
      {
        label: 'Light',
        icon: 'i-lucide-sun',
        type: 'checkbox' as const,
        checked: colorMode.value === 'light',
        onSelect(e: Event) {
          e.preventDefault()
          colorMode.preference = 'light'
        },
      },
      {
        label: 'Dark',
        icon: 'i-lucide-moon',
        type: 'checkbox' as const,
        checked: colorMode.value === 'dark',
        onSelect(e: Event) {
          e.preventDefault()
          colorMode.preference = 'dark'
        },
      },
      {
        label: 'System',
        icon: 'i-lucide-monitor',
        type: 'checkbox' as const,
        checked: colorMode.preference === 'system',
        onSelect(e: Event) {
          e.preventDefault()
          colorMode.preference = 'system'
        },
      },
    ],
  }],
])
</script>

<template>
  <UDropdownMenu :items="items" :content="{ align: 'center', side: 'right' }">
    <UButton
      color="neutral"
      variant="ghost"
      :label="collapsed ? undefined : 'Settings'"
      icon="i-lucide-settings"
      :square="collapsed"
      class="w-full"
      :class="collapsed ? 'justify-center' : 'justify-start'"
    />
  </UDropdownMenu>
</template>
