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

# Find and activate virtual environment
find_and_activate_venv() {
    for venv_path in ".venv" "venv" "env" "backend/.venv" "backend/venv"; do
        if [ -d "$venv_path" ] && [ -f "$venv_path/bin/activate" ]; then
            print_status "Found virtual environment at: $venv_path"
            source "$venv_path/bin/activate"
            print_success "Virtual environment activated"
            return 0
        fi
    done
    
    print_warning "No virtual environment found. Creating one..."
    python3 -m venv .venv
    source .venv/bin/activate
    print_success "Created and activated new virtual environment"
}

# Check Python version and dependencies
check_python() {
    print_status "Checking Python environment..."
    
    if ! command -v python3 >/dev/null 2>&1; then
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    local python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
    print_status "Python version: $python_version"
    
    # Check if key dependencies are installed
    if ! python3 -c "import fastapi, uvicorn, sqlalchemy" 2>/dev/null; then
        print_warning "Missing Python dependencies. Installing..."
        pip install -e .
    fi
    
    print_success "Python environment ready"
}

# Check Node.js version and dependencies
check_node() {
    print_status "Checking Node.js environment..."
    
    if ! command -v node >/dev/null 2>&1; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    local node_version=$(node --version | cut -d'v' -f2)
    print_status "Node.js version: $node_version"
    
    if [ ! -d "node_modules" ]; then
        print_warning "node_modules not found. Installing npm dependencies..."
        npm install
    fi
    
    print_success "Node.js environment ready"
}

# Start servers
start_servers() {
    print_status "Starting development servers..."
    
    # Start backend
    cd backend
    uvicorn open_webui.main:app --port 8080 --host 0.0.0.0 --forwarded-allow-ips '*' --reload &
    local backend_pid=$!
    cd ..
    
    # Wait a moment for backend to start
    sleep 2
    
    # Start frontend
    npm run dev &
    local frontend_pid=$!
    
    print_success "Development servers started!"
    print_status "Backend: http://localhost:8080"
    print_status "Frontend: http://localhost:5173"
    print_status "Press Ctrl+C to stop"
    
    # Wait for either process to exit
    wait $backend_pid $frontend_pid
}

# Main execution
main() {
    print_status "Starting DAMA_open-webui development environment..."
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ] || [ ! -f "pyproject.toml" ]; then
        print_error "Run this script from the project root directory"
        exit 1
    fi
    
    # Setup environment
    find_and_activate_venv
    check_python
    check_node
    
    # Start servers
    start_servers
}

# Handle Ctrl+C gracefully
trap 'print_status "Shutting down..."; exit 0' SIGINT SIGTERM

main "$@"