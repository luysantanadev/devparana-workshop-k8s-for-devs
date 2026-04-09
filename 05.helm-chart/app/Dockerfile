# syntax=docker/dockerfile:1

# ─── Builder ─────────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder
WORKDIR /build

# Enable corepack so pnpm is available without a global install
RUN corepack enable

# Copy manifests first for better layer caching
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./

# Install all dependencies (including devDeps needed for the build)
RUN pnpm install --frozen-lockfile

# Copy source
COPY . .

# Generate Nuxt types and build the server bundle → .output/
RUN pnpm build

# Compile instrumentation.ts → instrumentation.mjs alongside the Nitro output.
# No bundling: bare import specifiers are resolved from node_modules at runtime.
RUN ./node_modules/.bin/esbuild instrumentation.ts \
  --platform=node \
  --format=esm \
  --outfile=.output/server/instrumentation.mjs

# ─── Runner ──────────────────────────────────────────────────────────────────
FROM node:22-alpine AS runner
WORKDIR /app

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

# Nitro bundles app code into .output/server/index.mjs (self-contained).
# node_modules is required at runtime only for the OTel packages imported
# by instrumentation.mjs (sdk-node, auto-instrumentations-node, exporters, etc.)
# and for @opentelemetry/api externalized from the Nitro bundle.
COPY --from=builder /build/.output ./.output
COPY --from=builder /build/node_modules ./node_modules

EXPOSE 3000

# Run as non-root for security
USER node

# Load instrumentation BEFORE the Nitro server so OTel patches Node.js HTTP
# internals and registers the global tracer provider before any app code runs.
CMD ["node", "--import", "./.output/server/instrumentation.mjs", "./.output/server/index.mjs"]
