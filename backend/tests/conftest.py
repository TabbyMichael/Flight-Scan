import pytest
import tempfile
import json
import os
from pathlib import Path

@pytest.fixture
def temp_data_dir():
    """Create a temporary data directory for testing"""
    with tempfile.TemporaryDirectory() as temp_dir:
        data_dir = Path(temp_dir) / "data"
        data_dir.mkdir()
        
        # Create sample bookings file
        bookings_file = data_dir / "bookings.json"
        sample_bookings = {
            "bookings": [
                {
                    "id": "test-booking-1",
                    "pnr": "ABC123",
                    "status": "confirmed",
                    "created_at": "2023-01-01T10:00:00",
                    "flight_id": "flt_1",
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
            ]
        }
        with open(bookings_file, 'w') as f:
            json.dump(sample_bookings, f)
            
        yield data_dir

@pytest.fixture
def sample_booking_data():
    """Sample booking data for testing"""
    return {
        "flight_id": "flt_123",
        "passenger": {
            "first_name": "Jane",
            "last_name": "Smith",
            "email": "jane@example.com",
            "passport": "P87654321"
        },
        "extras": {"baggage": 2, "meal": 1},
        "total_price": 750.0,
        "currency": "USD"
    }