<template>
  <div>
    <NuxtRouteAnnouncer />
    <nav>
      <NuxtLink to="/users">Users</NuxtLink>
    </nav>
    <main>
      <NuxtPage />
    </main>
  </div>
</template>

<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: system-ui, sans-serif; color: #111827; background: #fff; }
nav { padding: 0.75rem 1.5rem; border-bottom: 1px solid #e5e7eb; display: flex; gap: 1.5rem; }
nav a { text-decoration: none; color: #374151; font-weight: 500; }
nav a.router-link-active { color: #2563eb; }
main { padding: 2rem 1.5rem; max-width: 900px; margin: 0 auto; }
</style>
