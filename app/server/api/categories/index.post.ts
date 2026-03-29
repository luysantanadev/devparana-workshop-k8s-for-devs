export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  if (!body?.name || typeof body.name !== 'string' || body.name.trim() === '') {
    throw createError({ statusCode: 400, statusMessage: 'name is required' })
  }

  const name = body.name.trim()

  if (categoriesDb.some(c => c.name.toLowerCase() === name.toLowerCase())) {
    throw createError({ statusCode: 409, statusMessage: 'A category with that name already exists' })
  }

  const category: DbCategory = { id: nextId('categories'), name }
  categoriesDb.push(category)
  return category
})
