<script setup lang="ts">
const name = ref('')
const error = ref('')
const router = useRouter()

async function submit() {
  error.value = ''
  try {
    await $fetch('/api/categories', {
      method: 'POST',
      body: { name: name.value },
    })
    await router.push('/categories')
  } catch (err: any) {
    error.value = err?.data?.statusMessage ?? 'An error occurred'
  }
}
</script>

<template>
  <div class="form-wrapper">
    <h1>New Category</h1>

    <form @submit.prevent="submit">
      <label for="name">Name</label>
      <input id="name" v-model="name" type="text" placeholder="Enter name" required />

      <p v-if="error" class="error">{{ error }}</p>

      <div class="form-actions">
        <NuxtLink to="/categories" class="btn-secondary">Cancel</NuxtLink>
        <button type="submit" class="btn-primary">Create</button>
      </div>
    </form>
  </div>
</template>

<style scoped>
.form-wrapper {
  max-width: 480px;
}

h1 { margin-bottom: 1.5rem; }

label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.375rem;
}

input {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 1rem;
  margin-bottom: 1rem;
  box-sizing: border-box;
}

.error {
  color: #dc2626;
  margin-bottom: 1rem;
}

.form-actions {
  display: flex;
  gap: 0.75rem;
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
