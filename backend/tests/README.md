# SkyScan Flight API - Test Suite

[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![pytest](https://img.shields.io/badge/pytest-7.4.0-green.svg)](https://docs.pytest.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104.1-red.svg)](https://fastapi.tiangolo.com/)
[![License](https://img.shields.io/github/license/yourusername/skyscan-flight-viewer)](../../LICENSE)

Comprehensive test suite for the SkyScan Flight Viewer backend API, ensuring reliability, performance, and correctness of all API endpoints and business logic.

## Table of Contents

- [Features](#features)
- [Test Structure](#test-structure)
- [Installation & Setup](#installation--setup)
- [Running Tests](#running-tests)
- [Usage Examples](#usage-examples)
- [Test Configuration](#test-configuration)
- [Tech Stack](#tech-stack)
- [Coverage Reports](#coverage-reports)
- [Continuous Integration](#continuous-integration)
- [Writing New Tests](#writing-new-tests)
- [Test Categories](#test-categories)
- [Performance Testing](#performance-testing)
- [Security Testing](#security-testing)
- [License](#license)

## Features

- 🧪 **Unit Testing**: Comprehensive tests for individual functions and components
- 🔗 **Integration Testing**: End-to-end testing of API endpoints and workflows
- 📊 **Coverage Reporting**: Detailed code coverage analysis
- ⚡ **Performance Testing**: Load and stress testing capabilities
- 🛡️ **Security Testing**: Vulnerability scanning and security checks
- 🔄 **CI/CD Integration**: Automated testing in deployment pipelines
- 📈 **Test Reporting**: Detailed HTML and XML test reports
- 🎯 **Parallel Execution**: Concurrent test execution for faster results

## Test Structure

```
tests/
├── unit/                 # Unit tests for individual functions
│   ├── test_api_endpoints.py
│   ├── test_booking_manager.py
│   └── test_flight_processing.py
├── integration/          # Integration tests for API workflows
│   ├── test_booking_flow.py
│   └── test_flight_search.py
├── performance/          # Performance and load tests
│   └── flight_search_load.js (k6)
├── security/             # Security scanning scripts
│   └── bandit_config.ini
├── test_data/            # Test data and fixtures
│   ├── flights_sample.json
│   └── bookings_sample.json
├── conftest.py           # pytest configuration and fixtures
└── README.md             # This file
```

## Installation & Setup

### Prerequisites

- Python 3.8 or higher
- pip package manager
- Backend API dependencies installed

### Install Test Dependencies

```bash
# Navigate to backend directory
cd /path/to/skyscan/backend

# Install test dependencies
pip install -r requirements-test.txt --break-system-packages
```

### Virtual Environment (Recommended)

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-test.txt --break-system-packages
```

## Running Tests

### Run All Tests

```bash
python3 -m pytest tests/ -v
```

### Run Unit Tests Only

```bash
python3 -m pytest tests/unit/ -v
```

### Run Integration Tests Only

```bash
python3 -m pytest tests/integration/ -v
```

### Run Tests with Verbose Output

```bash
python3 -m pytest tests/ -v --tb=short
```

### Run Tests in Parallel

```bash
python3 -m pytest tests/ -n auto
```

## Usage Examples

### Basic Test Execution

```bash
# Run all tests with detailed output
python3 -m pytest tests/ -v

# Run tests and generate HTML report
python3 -m pytest tests/ --html=report.html --self-contained-html

# Run tests with coverage
python3 -m pytest tests/ --cov=app --cov-report=html --cov-report=term
```

### Selective Test Execution

```bash
# Run specific test file
python3 -m pytest tests/unit/test_api_endpoints.py

# Run specific test function
python3 -m pytest tests/unit/test_api_endpoints.py::test_get_flights

# Run tests matching pattern
python3 -m pytest tests/ -k "flight"
```

## Test Configuration

### pytest Configuration

The `pytest.ini` file in the backend root contains:

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --tb=short
```

### Environment Variables

Tests automatically use the same environment as the main application. For custom test environments:

```bash
# Set test database URL
export TEST_DATABASE_URL=sqlite:///./test.db

# Set test API base URL
export TEST_API_BASE_URL=http://localhost:8000
```

## Tech Stack

- **Test Framework**: pytest 7.4.0
- **Coverage Tool**: pytest-cov 4.1.0
- **HTML Reports**: pytest-html 3.2.0
- **HTTP Testing**: httpx 0.24.1
- **Mocking**: pytest-mock
- **Performance Testing**: k6
- **Security Scanning**: bandit
- **Parallel Execution**: pytest-xdist

### Key Dependencies

- `pytest==7.4.0` - Main test framework
- `pytest-cov==4.1.0` - Coverage reporting
- `pytest-html==3.2.0` - HTML test reports
- `httpx==0.24.1` - HTTP client for testing
- `requests==2.31.0` - HTTP library
- `fastapi==0.104.1` - For TestClient
- `k6` - Performance testing tool

## Coverage Reports

### Generate Coverage Report

```bash
# Generate terminal coverage report
python3 -m pytest tests/ --cov=app

# Generate HTML coverage report
python3 -m pytest tests/ --cov=app --cov-report=html

# Generate XML coverage report (for CI)
python3 -m pytest tests/ --cov=app --cov-report=xml
```

### Coverage Requirements

- **Unit Tests**: Minimum 85% coverage
- **Integration Tests**: Minimum 90% coverage for critical paths
- **Overall**: Minimum 80% coverage across all tests

## Continuous Integration

### GitHub Actions Workflow

Example workflow in `.github/workflows/test.yml`:

```yaml
name: Test Suite
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install -r requirements-test.txt
    - name: Run tests
      run: pytest tests/ --cov=app --cov-report=xml
    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

## Writing New Tests

### Test File Naming Convention

- Unit tests: `test_[module_name].py`
- Integration tests: `test_[feature]_[type].py`

### Basic Test Structure

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_example():
    """Test description"""
    # Arrange
    expected_result = "expected_value"
    
    # Act
    response = client.get("/endpoint")
    result = response.json()
    
    # Assert
    assert response.status_code == 200
    assert result == expected_result
```

### Using Fixtures

```python
import pytest

@pytest.fixture
def sample_flight_data():
    return {
        "id": "flt_123",
        "airline": "HV",
        "price": 594.09
    }

def test_process_flight_data(sample_flight_data):
    # Use fixture data
    result = process_flight(sample_flight_data)
    assert result is not None
```

## Test Categories

### Unit Tests

Located in `tests/unit/`:
- Test individual functions and methods
- Mock external dependencies
- Focus on business logic validation
- Fast execution time

### Integration Tests

Located in `tests/integration/`:
- Test API endpoints
- Validate complete workflows
- Test data persistence and retrieval
- Include error handling scenarios

### Performance Tests

Located in `tests/performance/`:
- Load testing with k6
- Stress testing scenarios
- Response time validation
- Throughput measurement

### Security Tests

Located in `tests/security/`:
- Static code analysis with bandit
- Dependency vulnerability scanning
- Input validation testing
- Authentication testing

## Performance Testing

### k6 Load Testing

Example performance test in `tests/performance/flight_search_load.js`:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  const payload = JSON.stringify({
    origin: 'RTM',
    destination: 'STN',
    passengers: 2
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  const res = http.post('http://localhost:8000/flights/search', payload, params);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });

  sleep(1);
}
```

### Running Performance Tests

```bash
# Install k6
npm install -g k6

# Run performance test
k6 run tests/performance/flight_search_load.js
```

## Security Testing

### Static Analysis with Bandit

```bash
# Install bandit
pip install bandit

# Run security scan
bandit -r app/ -f json -o bandit-report.json

# Run with specific severity level
bandit -r app/ -lll
```

### Dependency Scanning

```bash
# Scan for vulnerable dependencies
pip-audit -r requirements.txt
```

## License

This test suite is part of the SkyScan Flight Viewer project, licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.