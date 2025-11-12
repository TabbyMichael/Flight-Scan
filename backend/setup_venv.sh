#!/bin/bash

# Activate the virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install requirements
pip install -r requirements.txt
pip install -r requirements-test.txt

echo "Virtual environment is set up and activated!"
echo "To activate manually, run: source venv/bin/activate"