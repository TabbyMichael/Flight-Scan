#!/bin/bash

# Script to start both backend and frontend applications in separate terminals
# Usage: ./run_apps.sh

echo "🚀 SkyScan Flight Viewer - Application Runner"
echo "=========================================="

# Function to print section headers
print_header() {
    echo
    echo "=== $1 ==="
    echo
}

# Function to check if a process is running
is_running() {
    kill -0 $1 2>/dev/null
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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Start Backend
print_header "Starting Backend Server"

cd "/home/kzer00/Documents/SkyScan Flight Viewer/backend"

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Kill any existing processes on port 8000
kill_port 8000

# Start backend server in background
echo "Starting FastAPI server on http://localhost:8000..."
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!

# Give server time to start
sleep 3

if is_running $BACKEND_PID; then
    echo "✅ Backend server started successfully (PID: $BACKEND_PID)"
    echo "   API Documentation: http://localhost:8000/docs"
else
    echo "❌ Failed to start backend server"
    deactivate
    exit 1
fi

# Start Frontend in a new terminal
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

echo "🎉 Applications started successfully!"
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
    if is_running $BACKEND_PID; then
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

# Wait for processes
wait