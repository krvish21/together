FROM node:20-alpine AS runner
WORKDIR /app

# Install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application source
COPY src/ ./src/

# Create persistent storage and media upload directories
RUN mkdir -p data uploads

EXPOSE 4000

ENV PORT=4000
ENV NODE_ENV=production

CMD ["node", "src/index.js"]
