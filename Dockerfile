FROM node:20-alpine AS builder

WORKDIR /home/ghost

# Install system dependencies for native modules
RUN apk add --no-cache \
    libxml2-dev \
    libxslt-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    zlib-dev \
    redis \
    libmagic \
    librsvg-dev \
    && rm -rf /var/cache/apk/*

# Copy monorepo root files for dependency installation
COPY package.json yarn.lock ./

# Install dependencies using frozen lockfile
RUN yarn install --frozen-lockfile

# Copy application source code
COPY ghost/ ghost/
COPY e2e e2e/
COPY apps/ apps/

# Build all packages
RUN yarn build

# Runtime stage
FROM node:20-alpine

WORKDIR /home/ghost

# Create non-root user for security
RUN addgroup -g 1001 -S ghost && \
    adduser -u 1001 -S ghost -G ghost

# Install runtime system dependencies
RUN apk add --no-cache \
    libxml2 \
    libxslt \
    libjpeg-turbo \
    libpng \
    zlib \
    redis \
    libmagic \
    librsvg \
    && rm -rf /var/cache/apk/*

# Copy built artifacts and dependencies from builder
COPY --from=builder --chown=ghost:ghost /home/ghost/node_modules ./node_modules
COPY --from=builder --chown=ghost:ghost /home/ghost/ghost ./ghost
COPY --from=builder --chown=ghost:ghost /home/ghost/apps ./apps
COPY --from=builder --chown=ghost:ghost /home/ghost/e2e ./e2e

# Copy package.json for metadata
COPY --chown=ghost:ghost package.json ./

# Switch to non-root user
USER ghost

# Expose application port
EXPOSE 2368

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:2368/ghost/api/admin/ping/', (r) => { process.exit(r.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the primary service (Ghost core)
CMD ["node", "ghost/core/index.js"]