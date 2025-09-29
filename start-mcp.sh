#!/bin/bash
# Script to start MCP servers based on their type

SERVER_NAME=$1
PORT=$2
SERVER_DIR="/app/mcp_servers/$SERVER_NAME"

cd $SERVER_DIR

# Detect server type and start appropriately
if [ -f "server.py" ]; then
    echo "Starting Python server: $SERVER_NAME on port $PORT"
    exec python server.py --port $PORT
elif [ -f "build/src/index.js" ]; then
    echo "Starting TypeScript server: $SERVER_NAME on port $PORT"
    exec node build/src/index.js --port $PORT
elif [ -f "main.go" ]; then
    echo "Starting Go server: $SERVER_NAME on port $PORT"
    exec ./mcp_server_$SERVER_NAME --port $PORT
else
    echo "ERROR: Unknown server type for $SERVER_NAME"
    exit 1
fi
