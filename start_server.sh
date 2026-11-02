#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/server"
echo "Starting Together PostgreSQL & WebSocket Sync Server on port 4000..."
node src/index.js
