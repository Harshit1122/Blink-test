FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files for layer caching
COPY package.json yarn.lock ./
COPY packages/worker/package.json ./packages/worker/package.json

# Install dependencies
RUN yarn install --frozen-lockfile --production=false

# Copy source code
COPY packages/worker ./packages/worker

# Build the worker
RUN yarn workspace worker build

FROM node:20-alpine

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy built artifacts and production dependencies
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/packages/worker/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/packages/worker/package.json ./package.json

USER nodejs

CMD ["node", "dist/index.js"]