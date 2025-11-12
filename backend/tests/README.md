# SkyScan Flight API - Test Suite

Comprehensive test suite for the SkyScan Flight Viewer backend API, built with Python, FastAPI, and pytest.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Coverage](#coverage)
- [CI/CD Integration](#cicd-integration)
- [Performance Testing](#performance-testing)
- [License](#license)

## Features

- ✅ **Unit Tests** - Test individual functions and API endpoints
- ✅ **Integration Tests** - Verify interactions between components
- ✅ **Code Coverage** - Track test coverage with pytest-cov
- ✅ **CI/CD Ready** - GitHub Actions workflow integration
- ✅ **Performance Tests** - Load testing with k6
- ✅ **Security Scanning** - Dependency vulnerability checks

## Tech Stack

- [Python 3.9+](https://www.python.org/)
- [pytest](https://docs.pytest.org/) - Testing framework
- [FastAPI](https://fastapi.tiangolo.com/) - ASGI web framework
- [pytest-cov](https://pytest-cov.readthedocs.io/) - Coverage reporting
- [k6](https://k6.io/) - Performance testing
- [GitHub Actions](https://github.com/features/actions) - CI/CD

## Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install test dependencies:
   ```bash
   pip install -r tests/requirements-test.txt
   ```

## Running Tests

### Run all tests:
```bash
python -m pytest tests/ -v
```

### Run tests with coverage:
```bash
python -m pytest tests/ --cov=app --cov-report=html
```

### Run specific test types:
```bash
# Run unit tests only
python -m pytest tests/unit/ -v

# Run integration tests only
python -m pytest tests/integration/ -v
```

## Test Structure

```
tests/
├── unit/
│   ├── test_flight_endpoints.py     # API endpoint tests
│   └── test_models.py               # Data model tests
├── integration/
│   └── test_booking_manager.py      # Booking manager tests
├── performance/
│   └── flight_search_load.js        # k6 load test script
├── conftest.py                      # pytest configuration
├── requirements-test.txt            # Test dependencies
└── fixtures/
    └── test_data.json               # Test data files
```

## Coverage

Current test coverage is 79% across all modules:

- `app/booking_utils.py`: 100%
- `app/main.py`: 75%

To generate an HTML coverage report:
```bash
python -m pytest tests/ --cov=app --cov-report=html
```

The report will be available in `backend/htmlcov/index.html`.

## CI/CD Integration

Tests are automatically run on every push and pull request via GitHub Actions:

```yaml
# .github/workflows/ci.yml
jobs:
  backend-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    - name: Install dependencies
      run: |
        cd backend
        pip install -r requirements.txt
        pip install -r tests/requirements-test.txt
    - name: Run tests
      run: |
        cd backend
        python -m pytest tests/ --cov=app --cov-report=xml
```

## Performance Testing

Load testing is performed using k6:

```bash
# Run load test
k6 run tests/performance/flight_search_load.js
```

Performance test script (`tests/performance/flight_search_load.js`):
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 100 }, // Ramp up to 100 users
    { duration: '1m', target: 100 },  // Stay at 100 users
    { duration: '30s', target: 0 },   // Ramp down to 0 users
  ],
};

export default function () {
  let searchPayload = JSON.stringify({
    max_price: 800.0,
    max_stops: 1,
  });
  
  let params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  let res = http.post('http://localhost:8000/flights/search', searchPayload, params);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.