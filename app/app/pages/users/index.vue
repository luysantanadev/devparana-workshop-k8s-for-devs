<script setup lang="ts">
const { data: users, refresh } = await useFetch('/api/users')

async function remove(id: number) {
  if (!confirm('Delete this user?')) return
  await $fetch(`/api/users/${id}`, { method: 'DELETE' })
  await refresh()
}
</script>

<template>
  <div>
    <div class="header">
      <h1>Users</h1>
      <NuxtLink to="/users/new" class="btn-primary">New User</NuxtLink>
    </div>

    <table v-if="users?.length">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Created</th>
          <th>Updated</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.id">
          <td>{{ user.id }}</td>
          <td>{{ user.name }}</td>
          <td>{{ new Date(user.createdAt).toLocaleString() }}</td>
          <td>{{ new Date(user.updatedAt).toLocaleString() }}</td>
          <td class="actions">
            <NuxtLink :to="`/users/${user.id}/edit`" class="btn-secondary">Edit</NuxtLink>
            <button class="btn-danger" @click="remove(user.id)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>

    <p v-else class="empty">No users yet.</p>
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

.btn-primary, .btn-secondary, .btn-danger {
  padding: 0.375rem 0.75rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  cursor: pointer;
  border: none;
  text-decoration: none;
  display: inline-block;
}

.btn-primary  { background: #2563eb; color: #fff; }
.btn-secondary { background: #e5e7eb; color: #111827; }
.btn-danger   { background: #dc2626; color: #fff; }
</style>
