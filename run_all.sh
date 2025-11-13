#!/bin/bash

# Script to run tests for both backend and frontend, then start the application
# Usage: ./run_all.sh

set -e  # Exit on any error

echo "🚀 SkyScan Flight Viewer - Full Test and Run Script"
echo "=================================================="

# Function to print section headers
print_header() {
    echo
    echo "=== $1 ==="
    echo
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to kill processes on a port
kill_port() {
    local port=$1
    if lsof -i :$port > /dev/null 2>&1; then
        echo "Killing processes on port $port..."
        lsof -ti :$port | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

# Check prerequisites
print_header "Checking Prerequisites"

if ! command_exists python3; then
    echo "❌ Python 3 is not installed"
    exit 1
fi

if ! command_exists flutter; then
    echo "❌ Flutter is not installed"
    exit 1
fi

echo "✅ Python 3: $(python3 --version)"
echo "✅ Flutter: $(flutter --version | head -n 1)"

# Backend Tests
print_header "Running Backend Tests"

cd "/home/kzer00/Documents/SkyScan Flight Viewer/backend"

# Activate virtual environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

# Install/update dependencies
echo "Installing backend dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
pip install -r requirements-test.txt

# Run backend tests
echo "Running backend unit tests..."
if python3 -m pytest tests/unit/ -v; then
    echo "✅ Backend unit tests passed"
else
    echo "❌ Backend unit tests failed"
    deactivate
    exit 1
fi

echo "Running backend integration tests..."
if python3 -m pytest tests/integration/ -v; then
    echo "✅ Backend integration tests passed"
else
    echo "❌ Backend integration tests failed"
    deactivate
    exit 1
fi

# If all tests pass, start the backend server
print_header "Starting Backend Server"

cd "/home/kzer00/Documents/SkyScan Flight Viewer/backend"

# Kill any existing processes on port 8000
kill_port 8000

echo "Starting FastAPI server..."
# Run in background and save PID
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!

# Give the server a moment to start
sleep 3

# Check if the server is running
if kill -0 $BACKEND_PID 2>/dev/null; then
    echo "✅ Backend server started successfully (PID: $BACKEND_PID)"
else
    echo "❌ Failed to start backend server"
    deactivate
    exit 1
fi

# Start the Flutter app in a new terminal
print_header "Starting Flutter Application"

echo "✅ Backend is running at http://localhost:8000"
echo "✅ Backend Docs available at http://localhost:8000/docs"
echo ""
echo "🔄 Starting Flutter app in a new terminal..."
echo "⚠️  Please make sure you have an emulator/device connected"
echo ""

# Open new terminal for Flutter app with error handling
cd "/home/kzer00/Documents/SkyScan Flight Viewer/flight_viewer"
if command_exists gnome-terminal; then
    gnome-terminal --title="Flutter App" -- bash -c "cd '/home/kzer00/Documents/SkyScan Flight Viewer/flight_viewer' && echo 'Starting Flutter app...' && echo 'If you encounter NDK issues, delete the corrupted NDK folder and try again:' && echo 'rm -rf ~/Android/Sdk/ndk/28.2.13676358' && echo '' && flutter run; exec bash"
elif command_exists xterm; then
    xterm -title "Flutter App" -e bash -c "cd '/home/kzer00/Documents/SkyScan Flight Viewer/flight_viewer' && echo 'Starting Flutter app...' && echo 'If you encounter NDK issues, delete the corrupted NDK folder and try again:' && echo 'rm -rf ~/Android/Sdk/ndk/28.2.13676358' && echo '' && flutter run; exec bash"
else
    echo "⚠️  Could not detect terminal emulator. Please run 'flutter run' manually in the flight_viewer directory"
    echo "💡 If you encounter NDK issues, delete the corrupted NDK folder and try again:"
    echo "   rm -rf ~/Android/Sdk/ndk/28.2.13676358"
fi

echo "🎉 All tests passed! Applications are now running."
echo "   - Backend API: http://localhost:8000"
echo "   - Backend Docs: http://localhost:8000/docs"
echo "   - Flutter App: Check the new terminal window"
echo ""
echo "Press Enter to stop the backend server..."
read

# Cleanup function
cleanup() {
    echo
    echo "Shutting down backend server..."
    if ps -p $BACKEND_PID > /dev/null; then
        kill $BACKEND_PID
        echo "✅ Backend server stopped"
    fi
    
    # Deactivate virtual environment
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
        echo "✅ Virtual environment deactivated"
    fi
    
    echo "👋 Backend process stopped. Close the Flutter terminal manually."
}

# Set trap to cleanup on exit
trap cleanup EXIT INT TERM

# Wait for background processes
wait