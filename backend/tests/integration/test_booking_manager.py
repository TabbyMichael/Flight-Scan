import pytest
import json
import os
from pathlib import Path
from app.booking_utils import BookingManager

def test_booking_manager_initialization():
    """Test that BookingManager initializes correctly"""
    # Create a temporary directory for testing
    test_dir = Path(__file__).parent / "test_data"
    test_dir.mkdir(exist_ok=True)
    
    # Initialize BookingManager with test directory
    bm = BookingManager(str(test_dir))
    
    # Verify bookings file was created
    bookings_file = test_dir / "bookings.json"
    assert bookings_file.exists()
    
    # Verify file contains expected structure
    with open(bookings_file, 'r') as f:
        data = json.load(f)
        assert "bookings" in data
        assert isinstance(data["bookings"], list)
    
    # Clean up
    if bookings_file.exists():
        bookings_file.unlink()
    if test_dir.exists():
        test_dir.rmdir()

def test_create_booking():
    """Test creating a booking"""
    # Create a temporary directory for testing
    test_dir = Path(__file__).parent / "test_data"
    test_dir.mkdir(exist_ok=True)
    
    # Initialize BookingManager with test directory
    bm = BookingManager(str(test_dir))
    
    # Create a booking
    booking_data = {
        "flight_id": "flt_123",
        "passenger_email": "test@example.com",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "test@example.com",
            "passport": "P12345678"
        },
        "extras": {},
        "total_price": 500.00,
        "currency": "USD"
    }
    
    booking = bm.create_booking(booking_data)
    
    # Verify booking has required fields
    assert "id" in booking
    assert "pnr" in booking
    assert "status" in booking
    assert "created_at" in booking
    assert booking["status"] == "confirmed"
    assert booking["flight_id"] == "flt_123"
    
    # Clean up
    bookings_file = test_dir / "bookings.json"
    if bookings_file.exists():
        bookings_file.unlink()
    if test_dir.exists():
        test_dir.rmdir()

def test_get_user_bookings():
    """Test retrieving bookings for a user"""
    # Create a temporary directory for testing
    test_dir = Path(__file__).parent / "test_data"
    test_dir.mkdir(exist_ok=True)
    
    # Initialize BookingManager with test directory
    bm = BookingManager(str(test_dir))
    
    # Create bookings for different users
    booking1 = bm.create_booking({
        "flight_id": "flt_123",
        "passenger_email": "user1@example.com",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "user1@example.com",
            "passport": "P12345678"
        },
        "extras": {},
        "total_price": 500.00,
        "currency": "USD"
    })
    
    booking2 = bm.create_booking({
        "flight_id": "flt_456",
        "passenger_email": "user2@example.com",
        "passenger": {
            "first_name": "Jane",
            "last_name": "Smith",
            "email": "user2@example.com",
            "passport": "P87654321"
        },
        "extras": {},
        "total_price": 750.00,
        "currency": "USD"
    })
    
    # Get bookings for user1
    user1_bookings = bm.get_user_bookings("user1@example.com")
    assert len(user1_bookings) == 1
    assert user1_bookings[0]["id"] == booking1["id"]
    
    # Get bookings for user2
    user2_bookings = bm.get_user_bookings("user2@example.com")
    assert len(user2_bookings) == 1
    assert user2_bookings[0]["id"] == booking2["id"]
    
    # Clean up
    bookings_file = test_dir / "bookings.json"
    if bookings_file.exists():
        bookings_file.unlink()
    if test_dir.exists():
        test_dir.rmdir()

def test_get_booking_by_pnr():
    """Test retrieving a booking by PNR"""
    # Create a temporary directory for testing
    test_dir = Path(__file__).parent / "test_data"
    test_dir.mkdir(exist_ok=True)
    
    # Initialize BookingManager with test directory
    bm = BookingManager(str(test_dir))
    
    # Create a booking
    booking = bm.create_booking({
        "flight_id": "flt_123",
        "passenger_email": "test@example.com",
        "passenger": {
            "first_name": "John",
            "last_name": "Doe",
            "email": "test@example.com",
            "passport": "P12345678"
        },
        "extras": {},
        "total_price": 500.00,
        "currency": "USD"
    })
    
    # Retrieve booking by PNR
    retrieved_booking = bm.get_booking_by_pnr(booking["pnr"])
    assert retrieved_booking is not None
    assert retrieved_booking["id"] == booking["id"]
    assert retrieved_booking["pnr"] == booking["pnr"]
    
    # Try to retrieve non-existent booking
    non_existent = bm.get_booking_by_pnr("NONEXISTENT")
    assert non_existent is None
    
    # Clean up
    bookings_file = test_dir / "bookings.json"
    if bookings_file.exists():
        bookings_file.unlink()
    if test_dir.exists():
        test_dir.rmdir()