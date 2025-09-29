# Multi-MCP Dockerfile v2 - Properly handles Python, TypeScript, and Go servers
FROM node:20-slim AS node-builder

# Install build tools
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    golang-go \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy all MCP servers
COPY mcp_servers/ /build/mcp_servers/

# Build TypeScript projects
RUN for dir in /build/mcp_servers/*/; do \
        if [ -f "$dir/package.json" ]; then \
            echo "Building TypeScript project: $dir"; \
            cd "$dir" && npm install && npm run build || true; \
        fi \
    done

# Build Go projects
RUN for dir in /build/mcp_servers/*/; do \
        if [ -f "$dir/main.go" ]; then \
            echo "Building Go project: $dir"; \
            cd "$dir" && go build -o mcp_server_$(basename $dir) . || true; \
        fi \
    done

# Final stage
FROM python:3.12-slim

# Install Node.js, nginx, supervisor
RUN apt-get update && apt-get install -y \
    curl \
    nginx \
    supervisor \
    gcc \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built artifacts from builder
COPY --from=node-builder /build/mcp_servers/ /app/mcp_servers/

# Install Python dependencies for each Python server
RUN for dir in /app/mcp_servers/*/; do \
        if [ -f "$dir/requirements.txt" ]; then \
            echo "Installing Python dependencies for $dir"; \
            pip install --no-cache-dir -r "$dir/requirements.txt"; \
        fi \
    done

# Copy configuration files
COPY supervisord-v2.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx-internal.conf /etc/nginx/nginx.conf
COPY start-mcp.sh /app/start-mcp.sh
RUN chmod +x /app/start-mcp.sh

# Create log directories
RUN mkdir -p /var/log/supervisor /var/log/nginx

# Expose port 80 for nginx
EXPOSE 80

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
