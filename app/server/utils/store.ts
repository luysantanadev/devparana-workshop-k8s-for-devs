const now = new Date().toISOString()

export interface DbCategory {
  id: number
  name: string
}

export interface DbUser {
  id: number
  name: string
  createdAt: string
  updatedAt: string
}

export interface DbTodo {
  id: number
  name: string
  description: string | null
  userId: number
  categoryId: number
  finishedAt: string | null
  createdAt: string
}

export const categoriesDb: DbCategory[] = [
  { id: 1, name: 'Work' },
  { id: 2, name: 'Personal' },
  { id: 3, name: 'Study' },
]

export const usersDb: DbUser[] = [
  { id: 1, name: 'Alice', createdAt: now, updatedAt: now },
  { id: 2, name: 'Bob', createdAt: now, updatedAt: now },
  { id: 3, name: 'Charlie', createdAt: now, updatedAt: now },
]

export const todosDb: DbTodo[] = [
  { id: 1, name: 'Setup project', description: 'Initialize Nuxt 4 project', userId: 1, categoryId: 1, finishedAt: now, createdAt: now },
  { id: 2, name: 'Write tests', description: null, userId: 2, categoryId: 1, finishedAt: null, createdAt: now },
  { id: 3, name: 'Read book', description: 'Clean Code', userId: 3, categoryId: 3, finishedAt: null, createdAt: now },
]

const _ids = { categories: 4, users: 4, todos: 4 }

export function nextId(entity: keyof typeof _ids): number {
  return _ids[entity]++
}
