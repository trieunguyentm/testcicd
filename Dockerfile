# # Stage 1: Build the app
# FROM node:18-alpine AS builder

# WORKDIR /app

# # Copy package.json and package-lock.json and install dependencies
# COPY package.json ./
# COPY package-lock.json ./
# RUN npm install

# # Copy rest of the application code
# COPY . .

# # Build the Next.js app
# RUN npm run build

# # Stage 2: Serve the app
# FROM node:18-alpine AS runner

# WORKDIR /app

# # Copy the build output from the builder stage
# COPY --from=builder /app ./

# # Expose port to serve the app
# EXPOSE 3000

# # Start the Next.js application
# CMD ["npm", "start"]
# Sử dụng base image node:20-alpine cho giai đoạn builder
FROM node:20-alpine AS builder

# Tạo thư mục làm việc
WORKDIR /app

# Copy file package.json và package-lock.json để cài đặt dependencies
COPY package*.json ./

# Cài đặt denpendencies
RUN npm ci
# RUN npm install

# Copy mã nguồn vào Container
COPY . .

# Build ứng dụng Next.js
RUN npm run build

# Tạo giai đoạn production, sử dụng lại giai đoạn builder
FROM node:20-alpine AS production

# Thiết lập biến môi trường cho production
ENV NODE_ENV=production

# Tạo thư mục làm việc
WORKDIR /app

# Copy các file từ builder sang production
COPY --from=builder /app/.next ./.next
# COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Dọn dẹp các devDependencies để giảm kích thước image
RUN npm prune --production

# Dọn dẹp cache npm để giảm kích thước image
RUN npm cache clean --force

# Tạo một user không phải root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose port 3000
EXPOSE 3000

# Chạy ứng dụng
CMD [ "npm", "start" ]