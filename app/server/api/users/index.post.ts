export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  if (!body?.name || typeof body.name !== 'string' || body.name.trim() === '') {
    throw createError({ statusCode: 400, statusMessage: 'name is required' })
  }

  const name = body.name.trim()

  if (usersDb.some(u => u.name.toLowerCase() === name.toLowerCase())) {
    throw createError({ statusCode: 409, statusMessage: 'A user with that name already exists' })
  }

  const now = new Date().toISOString()
  const user: DbUser = { id: nextId('users'), name, createdAt: now, updatedAt: now }
  usersDb.push(user)
  return user
})
