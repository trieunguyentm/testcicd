# Stage 1: Cài đặt dependencies (chỉ cho production)
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Stage 2: Build ứng dụng
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Thiết lập output dạng standalone trong next.config.js
# { "output": "standalone" }
RUN npm run build

# Stage 3: Image cho production
FROM node:20-alpine AS runner
WORKDIR /app

# Thiết lập biến môi trường cho production
ENV NODE_ENV=production

# Copy các tệp cần thiết từ builder
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
# COPY --from=builder /app/public ./public

# Tạo user không phải root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose port 3000
EXPOSE 3000

# Chạy ứng dụng
CMD ["node", "server.js"]
