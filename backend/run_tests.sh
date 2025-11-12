#!/bin/bash

# Script to run tests in the virtual environment

echo "Activating virtual environment..."
source venv/bin/activate

echo "Running backend unit tests..."
python -m pytest tests/unit/ -v

echo "Running backend integration tests..."
python -m pytest tests/integration/ -v

echo "To run specific test files, use:"
echo "python -m pytest tests/unit/test_database.py -v"
echo "python -m pytest tests/unit/test_booking_utils.py -v"

echo ""
echo "To activate the virtual environment manually, run:"
echo "source venv/bin/activate"