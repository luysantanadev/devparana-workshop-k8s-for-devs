export default defineEventHandler(() => {
  return [...categoriesDb].sort((a, b) => a.name.localeCompare(b.name))
})
