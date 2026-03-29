export default defineEventHandler((event) => {
  const id = parseInt(getRouterParam(event, 'id') ?? '')

  if (isNaN(id)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid id' })
  }

  const index = categoriesDb.findIndex(c => c.id === id)

  if (index === -1) {
    throw createError({ statusCode: 404, statusMessage: 'Category not found' })
  }

  categoriesDb.splice(index, 1)
  return { success: true }
})
