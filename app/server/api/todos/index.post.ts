export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  if (!body?.name || typeof body.name !== 'string' || body.name.trim() === '') {
    throw createError({ statusCode: 400, statusMessage: 'name is required' })
  }

  const userId = Number(body.userId)
  const categoryId = Number(body.categoryId)

  if (!userId || isNaN(userId)) {
    throw createError({ statusCode: 400, statusMessage: 'userId is required' })
  }
  if (!categoryId || isNaN(categoryId)) {
    throw createError({ statusCode: 400, statusMessage: 'categoryId is required' })
  }

  const todo: DbTodo = {
    id: nextId('todos'),
    name: body.name.trim(),
    description: body.description?.trim() || null,
    finishedAt: body.finishedAt ? new Date(body.finishedAt).toISOString() : null,
    userId,
    categoryId,
    createdAt: new Date().toISOString(),
  }

  todosDb.push(todo)

  return {
    ...todo,
    user: usersDb.find(u => u.id === userId) ?? { id: userId, name: 'Unknown' },
    category: categoriesDb.find(c => c.id === categoryId) ?? { id: categoryId, name: 'Unknown' },
  }
})
