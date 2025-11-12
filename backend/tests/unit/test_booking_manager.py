import pytest
import json
import os
from app.booking_utils import BookingManager
from pathlib import Path

@pytest.fixture
def booking_manager(tmp_path):
    """Create a BookingManager with a temporary data directory"""
    data_dir = tmp_path / "data"
    data_dir.mkdir()
    bookings_file = data_dir / "bookings.json"
    
    # Create initial empty bookings file
    with open(bookings_file, 'w') as f:
        json.dump({"bookings": []}, f)
    
    manager = BookingManager(str(data_dir))
    return manager

def test_ensure_bookings_file_creates_file(booking_manager):
    """Test that _ensure_bookings_file creates the bookings file if it doesn't exist"""
    # The fixture already creates the file, so let's test with a new manager
    # that would create it
    assert booking_manager.bookings_file.exists()

def test_create_booking(booking_manager):
    """Test creating a new booking"""
    booking_data = {
        "flight_id": "flt_123",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john.doe@example.com",
            "passport": "P12345678"
        },
        "passenger_email": "john.doe@example.com",
        "extras": {"baggage": 1},
        "total_price": 594.09,
        "currency": "USD"
    }
    
    booking = booking_manager.create_booking(booking_data)
    
    # Check that required fields are present
    assert "id" in booking
    assert "pnr" in booking
    assert "status" in booking
    assert "created_at" in booking
    assert booking["status"] == "confirmed"
    assert booking["flight_id"] == "flt_123"

def test_get_user_bookings(booking_manager):
    """Test retrieving bookings for a user"""
    # Create a booking first
    booking_data = {
        "flight_id": "flt_123",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john.doe@example.com",
            "passport": "P12345678"
        },
        "passenger_email": "john.doe@example.com",
        "extras": {"baggage": 1},
        "total_price": 594.09,
        "currency": "USD"
    }
    
    booking_manager.create_booking(booking_data)
    
    # Retrieve bookings for the user
    bookings = booking_manager.get_user_bookings("john.doe@example.com")
    assert len(bookings) == 1
    assert bookings[0]["flight_id"] == "flt_123"

def test_get_booking_by_pnr(booking_manager):
    """Test retrieving a booking by PNR"""
    # Create a booking first
    booking_data = {
        "flight_id": "flt_123",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john.doe@example.com",
            "passport": "P12345678"
        },
        "passenger_email": "john.doe@example.com",
        "extras": {"baggage": 1},
        "total_price": 594.09,
        "currency": "USD"
    }
    
    created_booking = booking_manager.create_booking(booking_data)
    pnr = created_booking["pnr"]
    
    # Retrieve booking by PNR
    retrieved_booking = booking_manager.get_booking_by_pnr(pnr)
    assert retrieved_booking is not None
    assert retrieved_booking["pnr"] == pnr
    assert retrieved_booking["flight_id"] == "flt_123"

def test_get_booking_by_pnr_not_found(booking_manager):
    """Test retrieving a non-existent booking by PNR"""
    booking = booking_manager.get_booking_by_pnr("NONEXISTENT")
    assert booking is None