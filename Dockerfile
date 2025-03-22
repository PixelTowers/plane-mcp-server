# Use Node.js image for building the project
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies without running scripts to prevent automatic build
RUN npm install --ignore-scripts

# Copy the entire source directory
COPY src ./src
COPY tsconfig.json ./

# Build the project
RUN npm run build

# Use a minimal Node.js image for running the project
FROM node:20-alpine AS release

# Set the working directory
WORKDIR /app

# Copy the built files from the builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json

# Install production dependencies
RUN npm ci --ignore-scripts --omit=dev

# Set environment variables as placeholders (override at runtime)
ENV PLANE_API_KEY=""
ENV PLANE_WORKSPACE_SLUG=""

# Set the command to run the server
ENTRYPOINT ["node", "dist/index.js"] 