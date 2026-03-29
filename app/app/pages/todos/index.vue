<script setup lang="ts">
const { data: todos, refresh } = await useFetch('/api/todos')

async function remove(id: number) {
  if (!confirm('Delete this todo?')) return
  await $fetch(`/api/todos/${id}`, { method: 'DELETE' })
  await refresh()
}

function formatDate(value: string | null | undefined) {
  if (!value) return '—'
  return new Date(value).toLocaleString()
}
</script>

<template>
  <div>
    <div class="header">
      <h1>Todos</h1>
      <NuxtLink to="/todos/new" class="btn-primary">New Todo</NuxtLink>
    </div>

    <table v-if="todos?.length">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Description</th>
          <th>User</th>
          <th>Category</th>
          <th>Created</th>
          <th>Finished</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="todo in todos" :key="todo.id">
          <td>{{ todo.id }}</td>
          <td>{{ todo.name }}</td>
          <td>{{ todo.description ?? '—' }}</td>
          <td>{{ todo.user.name }}</td>
          <td>{{ todo.category.name }}</td>
          <td>{{ formatDate(todo.createdAt) }}</td>
          <td>{{ formatDate(todo.finishedAt) }}</td>
          <td class="actions">
            <NuxtLink :to="`/todos/${todo.id}/edit`" class="btn-secondary">Edit</NuxtLink>
            <button class="btn-danger" @click="remove(todo.id)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>

    <p v-else class="empty">No todos yet.</p>
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
