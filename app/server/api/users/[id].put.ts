export default defineEventHandler(async (event) => {
  const id = parseInt(getRouterParam(event, 'id') ?? '')

  if (isNaN(id)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid id' })
  }

  const body = await readBody(event)

  if (!body?.name || typeof body.name !== 'string' || body.name.trim() === '') {
    throw createError({ statusCode: 400, statusMessage: 'name is required' })
  }

  const name = body.name.trim()
  const index = usersDb.findIndex(u => u.id === id)

  if (index === -1) {
    throw createError({ statusCode: 404, statusMessage: 'User not found' })
  }

  if (usersDb.some(u => u.id !== id && u.name.toLowerCase() === name.toLowerCase())) {
    throw createError({ statusCode: 409, statusMessage: 'A user with that name already exists' })
  }

  usersDb[index]!.name = name
  usersDb[index]!.updatedAt = new Date().toISOString()
  return usersDb[index]
})
