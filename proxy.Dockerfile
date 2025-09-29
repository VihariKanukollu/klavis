FROM nginx:1.25-alpine

# Copy nginx configuration with all MCP routing
COPY nginx.conf /etc/nginx/nginx.conf

# Create health check endpoint
RUN mkdir -p /usr/share/nginx/html && echo "ok" > /usr/share/nginx/html/healthz

EXPOSE 8080

# Use envsubst to replace ${PORT} in nginx.conf at runtime
CMD ["sh", "-c", "envsubst '$$PORT' < /etc/nginx/nginx.conf > /tmp/nginx.conf && nginx -c /tmp/nginx.conf -g 'daemon off;'"]
