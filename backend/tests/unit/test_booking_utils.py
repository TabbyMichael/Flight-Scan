import pytest
from unittest.mock import patch, mock_open, MagicMock
import json
import tempfile
from pathlib import Path
from app.booking_utils import BookingManager

class TestBookingManager:
    """Test suite for BookingManager class"""
    
    def test_init(self):
        """Test BookingManager initialization"""
        with tempfile.TemporaryDirectory() as temp_dir:
            data_dir = Path(temp_dir) / "data"
            manager = BookingManager(str(data_dir))
            assert manager.data_dir == data_dir
            assert manager.bookings_file == data_dir / "bookings.json"
    
    def test_ensure_bookings_file_creates_file(self):
        """Test that _ensure_bookings_file creates bookings file if it doesn't exist"""
        with tempfile.TemporaryDirectory() as temp_dir:
            data_dir = Path(temp_dir) / "data"
            manager = BookingManager(str(data_dir))
            
            # Check that file was created
            assert manager.bookings_file.exists()
            
            # Check file content
            with open(manager.bookings_file, 'r') as f:
                data = json.load(f)
                assert "bookings" in data
                assert data["bookings"] == []
    
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
            assert "created_at" in booking
            
            # Check that booking data is correct
            assert booking["flight_id"] == "flt_123"
            assert booking["passenger_email"] == "test@example.com"
            assert booking["status"] == "confirmed"
    
    def test_get_user_bookings(self):
        """Test getting bookings for a user"""
        with tempfile.TemporaryDirectory() as temp_dir:
            data_dir = Path(temp_dir) / "data"
            manager = BookingManager(str(data_dir))
            
            # Create test bookings
            booking1 = manager.create_booking({
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
            })
            
            booking2 = manager.create_booking({
                "flight_id": "flt_2",
                "passenger_email": "other@example.com",
                "passenger": {
                    "first_name": "Jane",
                    "last_name": "Smith",
                    "email": "other@example.com",
                    "passport": "P87654321"
                },
                "extras": {"baggage": 2},
                "total_price": 750.0,
                "currency": "USD"
            })
            
            # Get bookings for test user
            user_bookings = manager.get_user_bookings("test@example.com")
            
            assert len(user_bookings) == 1
            assert user_bookings[0]["id"] == booking1["id"]
            assert user_bookings[0]["passenger_email"] == "test@example.com"
    
    def test_get_booking_by_pnr(self):
        """Test getting booking by PNR"""
        with tempfile.TemporaryDirectory() as temp_dir:
            data_dir = Path(temp_dir) / "data"
            manager = BookingManager(str(data_dir))
            
            # Create a booking
            booking = manager.create_booking({
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
            })
            
            # Get booking by PNR
            found_booking = manager.get_booking_by_pnr(booking["pnr"])
            
            assert found_booking is not None
            assert found_booking["id"] == booking["id"]
            assert found_booking["pnr"] == booking["pnr"]
            
            # Test with non-existent PNR
            not_found = manager.get_booking_by_pnr("NONEXISTENT")
            assert not_found is None