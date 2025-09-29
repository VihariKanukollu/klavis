# Multi-MCP Dockerfile - Runs all 50+ MCP servers in one container
FROM node:20-slim

# Install nginx and supervisor
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy all MCP server code
COPY mcp_servers/ /app/mcp_servers/

# Install dependencies for each MCP server
RUN for dir in /app/mcp_servers/*/; do \
        if [ -f "$dir/package.json" ]; then \
            echo "Installing dependencies for $dir"; \
            cd "$dir" && npm install --production; \
        fi \
    done

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx-internal.conf /etc/nginx/nginx.conf

# Create log directories
RUN mkdir -p /var/log/supervisor /var/log/nginx

# Expose port 80 for nginx
EXPOSE 80

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
