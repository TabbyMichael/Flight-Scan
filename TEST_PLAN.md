# SkyScan Flight Viewer - Test Plan & Suite Implementation

## Executive Summary

This document outlines a comprehensive test plan for the SkyScan Flight Viewer application, covering backend API testing, frontend UI testing, and end-to-end integration testing. The plan includes unit tests for core business logic, integration tests for API endpoints, and automated test suites that can be run in CI/CD pipelines.

## Test Objectives & Scope

### Objectives
1. Ensure backend API endpoints function correctly
2. Validate booking and flight search functionality
3. Verify data persistence and retrieval
4. Test error handling and edge cases
5. Ensure frontend UI components work as expected
6. Validate end-to-end user workflows

### Scope
- Backend: FastAPI application with booking and flight search endpoints
- Frontend: Flutter mobile application
- Data: JSON file-based storage (migrating to PostgreSQL)
- APIs: RESTful endpoints for flights, bookings, and user management

## Test Strategy

### Test Types
1. **Unit Testing** - Test individual functions and classes
2. **Integration Testing** - Test API endpoints and service interactions
3. **End-to-End Testing** - Test complete user workflows
4. **Performance Testing** - Test API response times and throughput
5. **Security Testing** - Validate authentication and data protection

### Success Criteria
- Unit test coverage: 80%+
- Integration test coverage: 90%+
- All critical and high-priority bugs resolved
- API response times < 500ms for 95% of requests
- Zero critical security vulnerabilities

## Test Matrix

| Feature/Component | Unit Tests | Integration Tests | E2E Tests | Security Tests | Performance Tests |
|-------------------|------------|-------------------|-----------|----------------|-------------------|
| Booking Creation | ✅ | ✅ | ✅ | ✅ | ✅ |
| Flight Search | ✅ | ✅ | ✅ |  | ✅ |
| User Authentication |  | ✅ | ✅ | ✅ |  |
| Data Persistence | ✅ | ✅ |  |  |  |
| API Endpoints |  | ✅ |  |  |  |
| UI Components |  |  | ✅ |  |  |

## Test Cases

### Booking Creation
1. **TC001**: Create booking with valid data (Happy Path)
2. **TC002**: Create booking with missing required fields (Negative Case)
3. **TC003**: Create booking with invalid email format (Edge Case)

### Flight Search
1. **TC004**: Search flights with origin and destination (Happy Path)
2. **TC005**: Search flights with non-existent route (Negative Case)
3. **TC006**: Search flights with price and stops filters (Edge Case)

### User Authentication
1. **TC007**: User login with valid credentials (Happy Path)
2. **TC008**: User login with invalid credentials (Negative Case)
3. **TC009**: User registration with duplicate email (Edge Case)

## Automated Test Suite Plan

### Folder Structure
```
backend/
├── tests/
│   ├── unit/
│   │   ├── test_booking_utils.py
│   │   └── __init__.py
│   ├── integration/
│   │   ├── test_booking_endpoints.py
│   │   ├── test_flight_endpoints.py
│   │   └── __init__.py
│   ├── conftest.py
│   └── __init__.py
├── pytest.ini
└── requirements-test.txt
```

### Naming Conventions
- Test files: `test_*.py`
- Test classes: `Test*`
- Test methods: `test_*`

### Helper Utilities
- `conftest.py` for pytest fixtures
- Temporary data directories for isolated tests
- Sample data generators

## Example Tests

### Unit Test Example
```python
# tests/unit/test_booking_utils.py
def test_create_booking(self):
    """Test creating a new booking"""
    with tempfile.TemporaryDirectory() as temp_dir:
        data_dir = Path(temp_dir) / "data"
        manager = BookingManager(str(data_dir))
        
        booking_data = {
            "flight_id": "flt_123",
            "passenger_email": "test@example.com",
            "passenger": {
                "first_name": "John",
                "last_name": "Doe",
                "email": "test@example.com",
                "passport": "P12345678"
            },
            "extras": {"baggage": 1},
            "total_price": 500.0,
            "currency": "USD"
        }
        
        booking = manager.create_booking(booking_data)
        
        # Check that booking has required fields
        assert "id" in booking
        assert "pnr" in booking
        assert "status" in booking
```

### Integration Test Example
```python
# tests/integration/test_booking_endpoints.py
def test_create_booking_success(self):
    """Test successful booking creation"""
    booking_data = {
        "flight_id": "flt_123",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john.doe@example.com",
            "passport": "P12345678"
        },
        "extras": {"baggage": 1},
        "total_price": 500.0,
        "currency": "USD"
    }
    
    response = client.post("/bookings", json=booking_data)
    assert response.status_code == 200
```

### Commands to Run Tests
```bash
# Run unit tests only
python -m pytest tests/unit/ -v

# Run integration tests only
python -m pytest tests/integration/ -v

# Run all tests with coverage
python -m pytest tests/ -v --cov=app --cov-report=html

# Run tests in parallel
python -m pytest tests/ -v -n auto
```

## Test Data & Fixtures

### Generation Approach
- Use pytest fixtures for reusable test data
- Create temporary directories for isolated file operations
- Use factory functions for complex data structures

### Sample Data
- Sample flight data from existing JSON files
- Test user accounts with known credentials
- Booking data with various combinations of extras

## CI/CD Integration

### GitHub Actions Workflow
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
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
        pip install -r requirements-test.txt
    - name: Run tests
      run: |
        cd backend
        python -m pytest tests/ -v --cov=app
```

## Performance & Load Testing Plan

### Scenarios
1. Concurrent booking creation (100 users)
2. Flight search with complex filters (1000 requests)
3. Database read operations under load

### Targets
- Response time < 500ms for 95% of requests
- Error rate < 1%
- Throughput > 100 requests/second

## Security & Fuzzing Plan

### OWASP Tests
- Input validation for all API endpoints
- Authentication and authorization checks
- Secure headers and CORS configuration

### Dependency Scanning
- Use `pip-audit` for Python dependencies
- Regular security updates

## Reliability, Chaos & Resilience Tests

### Failure Simulation
- Database connection failures
- Network timeouts
- File system errors

## Test Observability & Reporting

### Coverage
- Unit test coverage: 80%+
- Integration test coverage: 90%+

### Reports
- HTML coverage reports
- JUnit XML for CI/CD
- Performance metrics dashboards

## Quality Gates & Acceptance Criteria

### PR Requirements
- All tests must pass
- Coverage must not decrease by > 5%
- No critical or high severity issues

### Release Requirements
- 100% of critical tests pass
- Performance benchmarks met
- Security scan clean

## Prioritized Implementation Roadmap

### 30 Days
- [Medium] Implement unit tests for booking_utils (8 hours)
- [Medium] Implement integration tests for booking endpoints (12 hours)
- [Low] Set up CI/CD pipeline (6 hours)

### 60 Days
- [High] Implement integration tests for flight search endpoints (16 hours)
- [Medium] Add performance testing framework (12 hours)
- [Low] Implement security scanning (4 hours)

### 90 Days
- [High] Implement end-to-end tests (24 hours)
- [Medium] Add load testing scenarios (16 hours)
- [Low] Set up test reporting dashboard (8 hours)

## Risks & Mitigations

### Key Risks
1. **Test data management** - Mitigation: Use fixtures and temporary directories
2. **Flaky tests** - Mitigation: Proper isolation and retry mechanisms
3. **Test maintenance** - Mitigation: Clear naming conventions and documentation

## Deliverables Checklist

### Files to Add
- [x] `backend/tests/unit/test_booking_utils.py`
- [x] `backend/tests/integration/test_booking_endpoints.py`
- [x] `backend/tests/integration/test_flight_endpoints.py`
- [x] `backend/tests/conftest.py`
- [x] `backend/pytest.ini`
- [x] `backend/requirements-test.txt`

## Appendix

### Test Case Template
```
ID: TCXXX
Title: [Brief description]
Preconditions: [Setup requirements]
Steps:
1. [Step 1]
2. [Step 2]
Expected Result: [Expected outcome]
Test Data: [Input data]
```

### Bug Report Template
```
Title: [Concise description]
Environment: [OS, Browser, Version]
Steps to Reproduce:
1. [Step 1]
2. [Step 2]
Expected Result: [What should happen]
Actual Result: [What actually happened]
Severity: [Critical/High/Medium/Low]
```