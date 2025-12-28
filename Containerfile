# Use the Node.js lts base image with Alpine lts for the build stage
FROM node:lts-alpine AS base

# Install bash on Alpine
RUN apk add --no-cache bash

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and the production environment file to the working directory
COPY package.json .env.prod ./

# --- Development Stage (New) ---
# This is where your compose.yml will "stop" in the dev environment.
FROM base AS development    

# Install the dependencies specified in package.json
RUN npm install

# Copy the rest of the application source code to the working directory
COPY . .

# In development
CMD ["npm", "run", "dev"]

# --- Build (Production) Stage ---
FROM base AS build

# Install dependencies to compile.
RUN npm install

COPY . .

# If you have a specific .env.prod
COPY .env.prod .env

# Build the application
RUN npm run build

# Remove all .js files from the dist/src directory
RUN find ./dist/src -name "*.js" -type f -delete

# It cleans and installs only what's necessary to run the game.
RUN npm prune --production && npm cache clean --force

# Install only production dependencies and clean the npm cache
RUN npm install --only=production --omit=dev && npm cache clean --force

# --- Final Stage (Lean Production Image) ---
# Use the Node.js lts base image with Alpine lts for the final stage
FROM node:lts-alpine AS production

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy necessary files from the build stage to the final image
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist/src/ ./dist/
COPY --from=build /usr/src/app/node_modules ./node_modules
# The production .env file will already be included as the final .env file.
COPY --from=build /usr/src/app/.env ./.env

RUN ls ./dist

# Expose port 3000 for the application
EXPOSE 3000

# Command to run the application in production mode
CMD ["npm", "run", "start:prod"]