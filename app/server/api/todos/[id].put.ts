export default defineEventHandler(async (event) => {
  const id = parseInt(getRouterParam(event, 'id') ?? '')

  if (isNaN(id)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid id' })
  }

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

  const index = todosDb.findIndex(t => t.id === id)

  if (index === -1) {
    throw createError({ statusCode: 404, statusMessage: 'Todo not found' })
  }

  todosDb[index] = {
    ...todosDb[index]!,
    name: body.name.trim(),
    description: body.description?.trim() || null,
    finishedAt: body.finishedAt ? new Date(body.finishedAt).toISOString() : null,
    userId,
    categoryId,
  }

  const todo = todosDb[index]!
  return {
    ...todo,
    user: usersDb.find(u => u.id === userId) ?? { id: userId, name: 'Unknown' },
    category: categoriesDb.find(c => c.id === categoryId) ?? { id: categoryId, name: 'Unknown' },
  }
})
