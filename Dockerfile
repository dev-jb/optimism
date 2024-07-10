# Start from a base image that includes Node.js and Go binaries
FROM node:20-alpine as node_build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml for dependencies
COPY package.json pnpm-lock.yaml /app/

# Install pnpm
RUN npm install -g pnpm

# Install dependencies using pnpm
RUN pnpm install

# Use the official Golang image as the base
FROM golang:1.21 as op-node

# Use node_modules from node_build
COPY --from=node_build /app/node_modules /app/node_modules

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Install make
RUN apt-get update && apt-get install -y make

# Run `make op-node`
RUN make op-node

# Specify the entry point
ENTRYPOINT ["/bin/sh", "-c", "echo 'Placeholder entry point'; sleep infinity"]


# Use the official Golang image as the base
FROM golang:1.21 as op-batcher

COPY --from=node_build /app/node_modules /app/node_modules

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Install make
RUN apt-get update && apt-get install -y make

# Run `make abc`
RUN make op-batcher

# Specify the entry point
ENTRYPOINT ["/bin/sh", "-c", "echo 'Placeholder entry point'; sleep infinity"]

# Use the official Golang image as the base
FROM golang:1.21 as op-proposer

COPY --from=node_build /app/node_modules /app/node_modules

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Install make
RUN apt-get update && apt-get install -y make

# Run `make abc`
RUN make op-proposer

# Specify the entry point
ENTRYPOINT ["/bin/sh", "-c", "echo 'Placeholder entry point'; sleep infinity"]
