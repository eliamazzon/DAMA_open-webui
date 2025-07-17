#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if ngrok is installed
if ! command -v ngrok >/dev/null 2>&1; then
    print_error "ngrok is not installed. Please install ngrok first: https://ngrok.com/download"
    exit 1
fi

# Start ngrok for backend (8080)
print_status "Starting ngrok tunnel for backend (http://localhost:8080)..."
ngrok http 8080 --log=stdout > ngrok_backend.log 2>&1 &
BACKEND_NGROK_PID=$!
sleep 2

# Start ngrok for frontend (5173)
print_status "Starting ngrok tunnel for frontend (http://localhost:5173)..."
ngrok http 5173 --log=stdout > ngrok_frontend.log 2>&1 &
FRONTEND_NGROK_PID=$!
sleep 2

# Extract public URLs
grep_url() {
    grep -o 'https://[a-z0-9.-]*\.ngrok-free\.app' "$1" | head -n 1
}

BACKEND_URL="$(grep_url ngrok_backend.log)"
FRONTEND_URL="$(grep_url ngrok_frontend.log)"

# Wait for URLs to appear (max 10s)
for i in {1..10}; do
    if [ -z "$BACKEND_URL" ]; then
        sleep 1
        BACKEND_URL="$(grep_url ngrok_backend.log)"
    fi
    if [ -z "$FRONTEND_URL" ]; then
        sleep 1
        FRONTEND_URL="$(grep_url ngrok_frontend.log)"
    fi
    if [ -n "$BACKEND_URL" ] && [ -n "$FRONTEND_URL" ]; then
        break
    fi
done

if [ -n "$BACKEND_URL" ]; then
    print_success "Backend ngrok URL: $BACKEND_URL"
else
    print_error "Failed to get backend ngrok URL. Check ngrok_backend.log."
fi

if [ -n "$FRONTEND_URL" ]; then
    print_success "Frontend ngrok URL: $FRONTEND_URL"
else
    print_error "Failed to get frontend ngrok URL. Check ngrok_frontend.log."
fi

print_status "\nTo allow your frontend to talk to the backend, you must set the backend URL in your frontend to the ngrok backend URL above.\n"
print_status "For example, set the environment variable or config value used for API requests to: $BACKEND_URL"
print_status "\nShare the frontend ngrok URL with users. They will be able to access the app via: $FRONTEND_URL\n"

# Cleanup on exit
cleanup() {
    print_status "Shutting down ngrok tunnels..."
    kill $BACKEND_NGROK_PID $FRONTEND_NGROK_PID 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# Wait for ngrok processes
wait $BACKEND_NGROK_PID $FRONTEND_NGROK_PID 