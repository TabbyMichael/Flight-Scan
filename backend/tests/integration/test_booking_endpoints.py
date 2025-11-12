import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestBookingEndpoints:
    """Test suite for booking-related API endpoints"""
    
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
        
        data = response.json()
        assert "id" in data
        assert "pnr" in data
        assert "status" in data
        assert data["status"] == "confirmed"
        assert data["flight_id"] == "flt_123"
        assert data["passenger"]["email"] == "john.doe@example.com"
    
    def test_create_booking_missing_required_fields(self):
        """Test booking creation with missing required fields"""
        # Missing passenger data
        booking_data = {
            "flight_id": "flt_123",
            "extras": {"baggage": 1},
            "total_price": 500.0,
            "currency": "USD"
        }
        
        response = client.post("/bookings", json=booking_data)
        assert response.status_code == 422  # Validation error
    
    def test_get_user_bookings_success(self):
        """Test getting user bookings"""
        # First create a booking
        booking_data = {
            "flight_id": "flt_123",
            "passenger": {
                "first_name": "Jane",
                "last_name": "Smith",
                "email": "jane.smith@example.com",
                "passport": "P87654321"
            },
            "extras": {"baggage": 2},
            "total_price": 750.0,
            "currency": "USD"
        }
        
        create_response = client.post("/bookings", json=booking_data)
        assert create_response.status_code == 200
        
        # Now get the bookings for this user
        response = client.get("/bookings?email=jane.smith@example.com")
        assert response.status_code == 200
        
        bookings = response.json()
        assert len(bookings) >= 1
        assert bookings[0]["passenger"]["email"] == "jane.smith@example.com"
    
    def test_get_booking_by_pnr_success(self):
        """Test getting booking by PNR"""
        # First create a booking
        booking_data = {
            "flight_id": "flt_456",
            "passenger": {
                "first_name": "Bob",
                "last_name": "Johnson",
                "email": "bob.johnson@example.com",
                "passport": "P11111111"
            },
            "extras": {"meal": 1},
            "total_price": 300.0,
            "currency": "USD"
        }
        
        create_response = client.post("/bookings", json=booking_data)
        assert create_response.status_code == 200
        
        booking = create_response.json()
        pnr = booking["pnr"]
        
        # Now get the booking by PNR
        response = client.get(f"/trip/{pnr}")
        assert response.status_code == 200
        
        retrieved_booking = response.json()
        assert retrieved_booking["pnr"] == pnr
        assert retrieved_booking["flight_id"] == "flt_456"
    
    def test_get_booking_by_pnr_not_found(self):
        """Test getting non-existent booking by PNR"""
        response = client.get("/trip/NONEXISTENT")
        assert response.status_code == 404