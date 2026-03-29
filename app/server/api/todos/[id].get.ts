export default defineEventHandler((event) => {
  const id = parseInt(getRouterParam(event, 'id') ?? '')

  if (isNaN(id)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid id' })
  }

  const todo = todosDb.find(t => t.id === id)

  if (!todo) {
    throw createError({ statusCode: 404, statusMessage: 'Todo not found' })
  }

  return {
    ...todo,
    user: usersDb.find(u => u.id === todo.userId) ?? { id: todo.userId, name: 'Unknown' },
    category: categoriesDb.find(c => c.id === todo.categoryId) ?? { id: todo.categoryId, name: 'Unknown' },
  }
})
