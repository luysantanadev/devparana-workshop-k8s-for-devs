export default defineEventHandler((event) => {
  const id = parseInt(getRouterParam(event, 'id') ?? '')

  if (isNaN(id)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid id' })
  }

  const index = todosDb.findIndex(t => t.id === id)

  if (index === -1) {
    throw createError({ statusCode: 404, statusMessage: 'Todo not found' })
  }

  todosDb.splice(index, 1)
  return { success: true }
})
