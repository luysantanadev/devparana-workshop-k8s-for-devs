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
  const index = categoriesDb.findIndex(c => c.id === id)

  if (index === -1) {
    throw createError({ statusCode: 404, statusMessage: 'Category not found' })
  }

  if (categoriesDb.some(c => c.id !== id && c.name.toLowerCase() === name.toLowerCase())) {
    throw createError({ statusCode: 409, statusMessage: 'A category with that name already exists' })
  }

  categoriesDb[index]!.name = name
  return categoriesDb[index]
})
