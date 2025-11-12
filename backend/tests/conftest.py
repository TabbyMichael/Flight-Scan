import pytest
import sys
import os
from pathlib import Path

# Add the app directory to the path so we can import the app
sys.path.insert(0, str(Path(__file__).parent.parent / "app"))

@pytest.fixture
def test_data_dir():
    """Return the path to the test data directory"""
    return Path(__file__).parent / "fixtures"

@pytest.fixture
def sample_flight_data():
    """Sample flight data for testing"""
    return {
        "id": "flt_1",
        "airlineCode": "HV",
        "airlineName": "Transavia Airlines",
        "flightNumber": "6993",
        "departureAirport": "RTM",
        "arrivalAirport": "STN",
        "departureTime": "2025-12-21T12:55:00",
        "arrivalTime": "2025-12-21T12:50:00",
        "duration": 55,
        "price": 557.86,
        "stops": 0,
        "currency": "USD",
        "cabinClass": "BASIC",
        "segments": []
    }

@pytest.fixture
def sample_booking_data():
    """Sample booking data for testing"""
    return {
        "flight_id": "flt_1",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john.doe@example.com",
            "passport": "P12345678"
        },
        "extras": {},
        "total_price": 557.86,
        "currency": "USD"
    }