# Stage 1: Build the app
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package.json ./
COPY package-lock.json ./
RUN npm install

# Copy rest of the application code
COPY . .

# Build the Next.js app
RUN npm run build

# Stage 2: Serve the app
FROM node:18-alpine AS runner

WORKDIR /app

# Copy the build output from the builder stage
COPY --from=builder /app ./

# Expose port to serve the app
EXPOSE 3000

# Start the Next.js application
CMD ["npm", "start"]
