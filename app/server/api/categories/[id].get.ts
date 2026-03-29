export default defineEventHandler((event) => {
  const id = parseInt(getRouterParam(event, 'id') ?? '')

  if (isNaN(id)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid id' })
  }

  const category = categoriesDb.find(c => c.id === id)

  if (!category) {
    throw createError({ statusCode: 404, statusMessage: 'Category not found' })
  }

  return category
})
