#!/bin/bash

# Script to run tests for both backend and frontend
# Usage: ./run_tests.sh

set -e  # Exit on any error

echo "🧪 SkyScan Flight Viewer - Test Runner"
echo "======================================"

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
echo "Activating virtual environment..."
source venv/bin/activate

# Run backend tests
echo "Running backend unit tests..."
python -m pytest tests/unit/ -v

echo "Running backend integration tests..."
python -m pytest tests/integration/ -v

# Frontend Tests
print_header "Running Frontend Tests"

cd "/home/kzer00/Documents/SkyScan Flight Viewer/flight_viewer"

echo "Running Flutter tests..."
flutter test

echo
echo "🎉 All tests completed successfully!"
echo

# Deactivate virtual environment
deactivate