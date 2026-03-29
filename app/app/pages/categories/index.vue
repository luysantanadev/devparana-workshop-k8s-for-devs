<script setup lang="ts">
const { data: categories, refresh } = await useFetch('/api/categories')

async function remove(id: number) {
  if (!confirm('Delete this category?')) return
  await $fetch(`/api/categories/${id}`, { method: 'DELETE' })
  await refresh()
}
</script>

<template>
  <div>
    <div class="header">
      <h1>Categories</h1>
      <NuxtLink to="/categories/new" class="btn-primary">New Category</NuxtLink>
    </div>

    <table v-if="categories?.length">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="category in categories" :key="category.id">
          <td>{{ category.id }}</td>
          <td>{{ category.name }}</td>
          <td class="actions">
            <NuxtLink :to="`/categories/${category.id}/edit`" class="btn-secondary">Edit</NuxtLink>
            <button class="btn-danger" @click="remove(category.id)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>

    <p v-else class="empty">No categories yet.</p>
  </div>
</template>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid #e5e7eb;
}

th {
  font-weight: 600;
  background: #f9fafb;
}

.actions {
  display: flex;
  gap: 0.5rem;
}

.empty {
  color: #6b7280;
  text-align: center;
  padding: 2rem;
}
</style>
