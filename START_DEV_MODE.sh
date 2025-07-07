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

# Global variable to store the correct Python executable
PYTHON_EXE=""

# Check if Python version meets requirements (>= 3.11)
check_python_version() {
    local python_cmd="$1"
    if ! command -v "$python_cmd" >/dev/null 2>&1; then
        return 1
    fi
    
    local version_output=$($python_cmd --version 2>&1)
    local version=$(echo "$version_output" | cut -d' ' -f2)
    local major=$(echo "$version" | cut -d'.' -f1)
    local minor=$(echo "$version" | cut -d'.' -f2)
    
    # Check if version >= 3.11
    if [ "$major" -eq 3 ] && [ "$minor" -ge 11 ]; then
        return 0
    elif [ "$major" -gt 3 ]; then
        return 0
    else
        return 1
    fi
}

# Install Python 3.11 via Homebrew
install_python_311() {
    print_status "Installing Python 3.11 via Homebrew..."
    
    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew is not installed. Please install Homebrew first:"
        print_error "https://brew.sh"
        exit 1
    fi
    
    brew install python@3.11
    if [ $? -eq 0 ]; then
        print_success "Python 3.11 installed successfully"
        return 0
    else
        print_error "Failed to install Python 3.11"
        exit 1
    fi
}

# Find correct Python executable
find_correct_python() {
    print_status "Checking for compatible Python version (>= 3.11)..."
    
    # List of possible Python executables to check
    local python_candidates=(
        "python3.13"
        "python3.12"
        "python3.11"
        "/opt/homebrew/bin/python3.13"
        "/opt/homebrew/bin/python3.12"
        "/opt/homebrew/bin/python3.11"
        "python3"
        "python"
    )
    
    for python_cmd in "${python_candidates[@]}"; do
        if check_python_version "$python_cmd"; then
            PYTHON_EXE="$python_cmd"
            local version=$($python_cmd --version 2>&1 | cut -d' ' -f2)
            print_success "Found compatible Python: $python_cmd (version $version)"
            return 0
        fi
    done
    
    # No compatible Python found, try to install Python 3.11
    print_warning "No compatible Python version found (requires >= 3.11)"
    
    # Check current Python version for informative message
    if command -v python3 >/dev/null 2>&1; then
        local current_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        print_status "Current Python version: $current_version"
    fi
    
    # Install Python 3.11
    install_python_311
    
    # Try to use the newly installed Python
    if check_python_version "/opt/homebrew/bin/python3.11"; then
        PYTHON_EXE="/opt/homebrew/bin/python3.11"
        print_success "Using newly installed Python 3.11"
        return 0
    else
        print_error "Failed to set up compatible Python environment"
        exit 1
    fi
}

# Find and activate virtual environment
find_and_activate_venv() {
    # First ensure we have the correct Python
    find_correct_python
    
    for venv_path in ".venv" "venv" "env" "backend/.venv" "backend/venv"; do
        if [ -d "$venv_path" ] && [ -f "$venv_path/bin/activate" ]; then
            print_status "Found virtual environment at: $venv_path"
            source "$venv_path/bin/activate"
            
            # Check if the virtual environment uses a compatible Python version
            if check_python_version "python"; then
                print_success "Virtual environment activated with compatible Python"
                return 0
            else
                print_warning "Existing virtual environment uses incompatible Python version"
                print_status "Removing old virtual environment and creating new one..."
                rm -rf "$venv_path"
                break
            fi
        fi
    done
    
    print_status "Creating new virtual environment with Python $($PYTHON_EXE --version | cut -d' ' -f2)..."
    "$PYTHON_EXE" -m venv .venv
    source .venv/bin/activate
    print_success "Created and activated new virtual environment"
}

# Check Python version and dependencies
check_python() {
    print_status "Checking Python environment..."
    
    # Verify we're using the correct Python in the virtual environment
    local python_version=$(python --version 2>&1 | cut -d' ' -f2)
    print_status "Active Python version: $python_version"
    
    if ! check_python_version "python"; then
        print_error "Virtual environment is using incompatible Python version: $python_version"
        print_error "Open WebUI requires Python >= 3.11"
        exit 1
    fi
    
    # Check if key dependencies are installed
    if ! python -c "import fastapi, uvicorn, sqlalchemy" 2>/dev/null; then
        print_warning "Missing Python dependencies. Installing from requirements.txt..."
        
        # Install dependencies from requirements.txt
        if [ -f "backend/requirements.txt" ]; then
            pip install -r backend/requirements.txt
        else
            print_error "backend/requirements.txt not found"
            exit 1
        fi
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
    
    # Kill any existing processes on port 8080
    if lsof -ti:8080 >/dev/null 2>&1; then
        print_warning "Port 8080 is in use. Killing existing processes..."
        lsof -ti:8080 | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
    
    # Start backend
    cd backend
    uvicorn open_webui.main:app --port 8080 --host 0.0.0.0 --forwarded-allow-ips '*' --reload &
    local backend_pid=$!
    cd ..
    
    # Wait a moment for backend to start
    sleep 3
    
    # Check if backend started successfully
    if ! kill -0 $backend_pid 2>/dev/null; then
        print_error "Backend failed to start"
        exit 1
    fi
    
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