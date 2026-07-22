# Build stage
FROM ubuntu:22.04 AS builder

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools, compiler, cmake, openssl headers
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    clang \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy source files
COPY CMakeLists.txt main.cpp httplib.h index.html ./

# Build the project
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc)

# Runtime stage
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies (OpenSSL, CA certificates for HTTPS)
RUN apt-get update && apt-get install -y \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built binary and frontend file
COPY --from=builder /app/build/db /app/db
COPY --from=builder /app/index.html /app/index.html

# Expose port
EXPOSE 8080

# Set env defaults
ENV PORT=8080

# Start the application
CMD ["/app/db"]
