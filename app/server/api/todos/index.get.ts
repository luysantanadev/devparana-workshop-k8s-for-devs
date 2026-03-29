export default defineEventHandler(() => {
  return [...todosDb]
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .map(todo => ({
      ...todo,
      user: usersDb.find(u => u.id === todo.userId) ?? { id: todo.userId, name: 'Unknown' },
      category: categoriesDb.find(c => c.id === todo.categoryId) ?? { id: todo.categoryId, name: 'Unknown' },
    }))
})
