export default defineEventHandler(() => {
  return [...usersDb].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
})
