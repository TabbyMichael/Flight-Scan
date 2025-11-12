# SkyScan Flight Viewer

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104.1-green?logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue?logo=python)](https://www.python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12%2B-blue?logo=postgresql)](https://www.postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A flight search and booking application with Flutter frontend and FastAPI backend.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Setup](#setup)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Database](#database)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Scripts](#scripts)
- [Tech Stack](#tech-stack)
- [License](#license)

## Features

- 🛫 Flight search with advanced filtering options
- 📅 Booking management and history
- 🔐 Secure user authentication and registration
- 🧳 Extra services selection (baggage, meals, etc.)
- 💳 Payment simulation
- 🌙 Dark/light theme toggle
- 📱 Responsive mobile-first design

## Prerequisites

- Flutter SDK 3.x
- Python 3.8+
- PostgreSQL 12+
- Dart 3.x

## Quick Start

For a quick setup and run, use our automated scripts:

```bash
# Run everything (tests + applications in separate terminals)
./run_all.sh

# Run only applications (backend in current terminal, Flutter in new terminal)
./run_apps.sh

# Run only tests
./run_tests.sh
```

## Setup

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create and activate a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   pip install -r requirements-test.txt
   ```
   
   Or if using system Python on Linux:
   ```bash
   pip install --break-system-packages -r requirements.txt
   ```

4. Set up PostgreSQL database:
   ```bash
   python init_postgres_db.py
   ```

5. Start the backend server:
   ```bash
   uvicorn app.main:app --reload
   ```

### Frontend Setup

1. Navigate to the flight_viewer directory:
   ```bash
   cd flight_viewer
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Database

The application uses PostgreSQL for data storage. Refer to [POSTGRES_SETUP.md](backend/POSTGRES_SETUP.md) for detailed setup instructions.

To initialize the database:
```bash
cd backend
python init_postgres_db.py
```

## API Documentation

Once the backend server is running, visit:
- http://localhost:8000/docs - Interactive API documentation (Swagger UI)
- http://localhost:8000/redoc - Alternative API documentation (ReDoc)

## Testing

### Backend Testing

The backend includes comprehensive unit and integration tests:

```
backend/
├── tests/
│   ├── unit/
│   │   └── test_booking_utils.py
│   └── integration/
│       ├── test_booking_endpoints.py
│       └── test_flight_endpoints.py
```

Run unit tests:
```bash
cd backend
source venv/bin/activate
python3 -m pytest tests/unit/ -v
```

Run integration tests:
```bash
cd backend
source venv/bin/activate
python3 -m pytest tests/integration/ -v
```

Run all backend tests:
```bash
cd backend
source venv/bin/activate
python3 -m pytest tests/ -v
```

### Frontend Testing

Run Flutter tests:
```bash
cd flight_viewer
flutter test
```

## Scripts

The project includes several helpful scripts to streamline development. All scripts automatically manage the Python virtual environment:

### `run_all.sh`
Runs all tests and starts both backend and frontend applications:
```bash
./run_all.sh
```

### `run_tests.sh`
Runs all backend and frontend tests:
```bash
./run_tests.sh
```

### `run_apps.sh`
Starts both backend and frontend applications:
```bash
./run_apps.sh
```

All scripts will:
- Automatically create a virtual environment if one doesn't exist
- Activate the virtual environment
- Install required dependencies
- Run tests or applications as appropriate
- Properly clean up resources when finished

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile UI framework
- **Dart** - Programming language for Flutter
- **Provider** - State management solution
- **http** - HTTP client for API communication
- **shared_preferences** - Local data storage

### Backend
- **FastAPI** - Modern, fast (high-performance) web framework
- **Python** - Programming language
- **PostgreSQL** - Relational database
- **SQLAlchemy** - SQL toolkit and ORM
- **PyJWT** - JSON Web Token implementation
- **Uvicorn** - ASGI server

### Testing
- **pytest** - Python testing framework
- **flutter_test** - Flutter testing framework

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.