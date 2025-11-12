# SkyScan Flight API

[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104.1-green.svg)](https://fastapi.tiangolo.com/)
[![License](https://img.shields.io/github/license/yourusername/skyscan-flight-viewer)](LICENSE)

This is the backend API for the SkyScan Flight Search and Booking Management Application, built with Python and FastAPI.

## Table of Contents

- [Features](#features)
- [Installation & Setup](#installation--setup)
- [Running the API](#running-the-api)
- [API Documentation](#api-documentation)
- [Environment Variables](#environment-variables)
- [API Endpoints](#api-endpoints)
- [Tech Stack](#tech-stack)
- [Testing](#testing)
- [Development](#development)
- [License](#license)

## Features

- 🚀 **FastAPI Framework**: High-performance API with automatic documentation
- 🔍 **Flight Search**: Advanced flight search with filtering capabilities
- 🛒 **Booking Management**: Create and manage flight bookings
- 📋 **Flight Data**: Comprehensive flight information with pricing and details
- 🌐 **CORS Enabled**: Cross-origin resource sharing for frontend integration
- 📖 **Auto-generated Docs**: Interactive API documentation with Swagger/OpenAPI
- 🧪 **Comprehensive Testing**: Unit and integration tests with pytest

## Installation & Setup

### Prerequisites

- Python 3.8 or higher
- pip package manager

### Virtual Environment Setup (Recommended)

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Install Test Dependencies

```bash
pip install -r requirements-test.txt --break-system-packages
```

## Running the API

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, you can access:

- Interactive API documentation: http://localhost:8000/docs
- Alternative documentation: http://localhost:8000/redoc

## Environment Variables

Create a `.env` file in the root directory to set environment variables if needed.

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Health check |
| `GET` | `/flights` | Get all flights |
| `POST` | `/flights/search` | Search flights with filters |
| `GET` | `/airlines` | Get list of airlines |
| `GET` | `/services` | Get extra services |
| `GET` | `/trip/{pnr}` | Get trip details by PNR |
| `POST` | `/bookings` | Create a new booking |
| `GET` | `/bookings` | Get user bookings by email |

## Tech Stack

- **Backend**: Python 3.8+
- **Framework**: FastAPI 0.104.1
- **Data Validation**: Pydantic
- **ASGI Server**: Uvicorn
- **Testing**: pytest, httpx
- **Data Format**: JSON

### Key Dependencies

- `fastapi==0.104.1` - Web framework
- `uvicorn==0.24.0` - ASGI server
- `pydantic==2.4.2` - Data validation
- `python-multipart==0.0.6` - File upload support
- `python-dotenv==1.0.0` - Environment variable management
- `email-validator==2.3.0` - Email validation

## Testing

### Run All Tests

```bash
python3 -m pytest tests/ -v
```

### Run Unit Tests

```bash
python3 -m pytest tests/unit/ -v
```

### Run Integration Tests

```bash
python3 -m pytest tests/integration/ -v
```

### Run Tests with Coverage

```bash
python3 -m pytest tests/ --cov=app --cov-report=html
```

## Development

For development, you can use the `--reload` flag to enable auto-reload:

```bash
uvicorn app.main:app --reload
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.