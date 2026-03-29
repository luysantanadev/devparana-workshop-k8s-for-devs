<script setup lang="ts">
const route = useRoute()
const id = Number(route.params.id)
const router = useRouter()
const error = ref('')

const [{ data: todo }, { data: users }, { data: categories }] = await Promise.all([
  useFetch(`/api/todos/${id}`),
  useFetch('/api/users'),
  useFetch('/api/categories'),
])

function toDatetimeLocal(value: string | null | undefined) {
  if (!value) return ''
  return new Date(value).toISOString().slice(0, 16)
}

const form = reactive({
  name: todo.value?.name ?? '',
  description: todo.value?.description ?? '',
  finishedAt: toDatetimeLocal(todo.value?.finishedAt),
  userId: String(todo.value?.userId ?? ''),
  categoryId: String(todo.value?.categoryId ?? ''),
})

async function submit() {
  error.value = ''
  try {
    await $fetch(`/api/todos/${id}`, {
      method: 'PUT',
      body: {
        name: form.name,
        description: form.description || null,
        finishedAt: form.finishedAt || null,
        userId: Number(form.userId),
        categoryId: Number(form.categoryId),
      },
    })
    await router.push('/todos')
  } catch (err: any) {
    error.value = err?.data?.statusMessage ?? 'An error occurred'
  }
}
</script>

<template>
  <div class="form-wrapper">
    <h1>Edit Todo #{{ id }}</h1>

    <form @submit.prevent="submit">
      <label for="name">Name</label>
      <input id="name" v-model="form.name" type="text" placeholder="Enter name" required />

      <label for="description">Description</label>
      <textarea id="description" v-model="form.description" placeholder="Optional description" rows="3" />

      <label for="userId">Assigned to</label>
      <select id="userId" v-model="form.userId" required>
        <option value="" disabled>Select a user</option>
        <option v-for="u in users" :key="u.id" :value="String(u.id)">{{ u.name }}</option>
      </select>

      <label for="categoryId">Category</label>
      <select id="categoryId" v-model="form.categoryId" required>
        <option value="" disabled>Select a category</option>
        <option v-for="c in categories" :key="c.id" :value="String(c.id)">{{ c.name }}</option>
      </select>

      <label for="finishedAt">Finish date</label>
      <input id="finishedAt" v-model="form.finishedAt" type="datetime-local" />

      <p v-if="error" class="error">{{ error }}</p>

      <div class="form-actions">
        <NuxtLink to="/todos" class="btn-secondary">Cancel</NuxtLink>
        <button type="submit" class="btn-primary">Save</button>
      </div>
    </form>
  </div>
</template>

<style scoped>
.form-wrapper { max-width: 540px; }

h1 { margin-bottom: 1.5rem; }

label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.375rem;
  margin-top: 1rem;
}

label:first-of-type { margin-top: 0; }

input, textarea, select {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 1rem;
  box-sizing: border-box;
  font-family: inherit;
}

textarea { resize: vertical; }

.error {
  color: #dc2626;
  margin-top: 1rem;
}

.form-actions {
  display: flex;
  gap: 0.75rem;
  margin-top: 1.5rem;
}

.btn-primary, .btn-secondary {
  padding: 0.5rem 1.25rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  cursor: pointer;
  border: none;
  text-decoration: none;
  display: inline-block;
}

.btn-primary  { background: #2563eb; color: #fff; }
.btn-secondary { background: #e5e7eb; color: #111827; }
</style>
