import pytest
from unittest.mock import patch, MagicMock
import json
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)

class TestBookingFlow:
    """Integration tests for the booking flow"""
    
    def test_create_booking_success(self):
        """Test successful booking creation"""
        # Test data
        booking_data = {
            "flight_id": "flt_123",
            "passenger": {
                "first_name": "John",
                "last_name": "Doe",
                "email": "john@example.com",
                "passport": "P12345678"
            },
            "extras": {"baggage": 1},
            "total_price": 500.0
        }
        
        # Mock the booking manager
        with patch('app.main.booking_manager') as mock_booking_manager:
            mock_booking_manager.create_booking.return_value = {
                "id": "booking_123",
                "pnr": "ABC123",
                "status": "confirmed",
                "created_at": "2023-01-01T00:00:00",
                "flight_id": "flt_123",
                "passenger": {
                    "first_name": "John",
                    "last_name": "Doe",
                    "email": "john@example.com",
                    "passport": "P12345678"
                },
                "extras": {"baggage": 1},
                "total_price": 500.0,
                "currency": "USD",
                "user_email": "john@example.com"
            }
            
            # Send POST request
            response = client.post("/bookings", json=booking_data)
            
            # Verify response
            assert response.status_code == 200
            data = response.json()
            assert data["id"] == "booking_123"
            assert data["pnr"] == "ABC123"
            assert data["status"] == "confirmed"
            
            # Verify booking manager was called
            mock_booking_manager.create_booking.assert_called_once()

    def test_create_booking_validation_error(self):
        """Test booking creation with validation error"""
        # Test data with missing required fields
        booking_data = {
            "flight_id": "flt_123",
            # Missing passenger data
            "extras": {"baggage": 1},
            "total_price": 500.0
        }
        
        # Send POST request
        response = client.post("/bookings", json=booking_data)
        
        # Verify response
        assert response.status_code == 422  # Validation error

    def test_get_user_bookings_success(self):
        """Test successful retrieval of user bookings"""
        # Mock the booking manager
        with patch('app.main.booking_manager') as mock_booking_manager:
            mock_booking_manager.get_user_bookings.return_value = [
                {
                    "id": "booking_123",
                    "pnr": "ABC123",
                    "status": "confirmed",
                    "created_at": "2023-01-01T00:00:00",
                    "flight_id": "flt_123",
                    "passenger": {
                        "first_name": "John",
                        "last_name": "Doe",
                        "email": "john@example.com",
                        "passport": "P12345678"
                    },
                    "extras": {"baggage": 1},
                    "total_price": 500.0,
                    "currency": "USD",
                    "user_email": "john@example.com"
                }
            ]
            
            # Send GET request
            response = client.get("/bookings?email=john@example.com")
            
            # Verify response
            assert response.status_code == 200
            data = response.json()
            assert len(data) == 1
            assert data[0]["id"] == "booking_123"
            assert data[0]["pnr"] == "ABC123"
            
            # Verify booking manager was called
            mock_booking_manager.get_user_bookings.assert_called_once_with("john@example.com")

    def test_get_booking_by_pnr_success(self):
        """Test successful retrieval of booking by PNR"""
        # Mock the booking manager
        with patch('app.main.booking_manager') as mock_booking_manager:
            mock_booking_manager.get_booking_by_pnr.return_value = {
                "id": "booking_123",
                "pnr": "ABC123",
                "status": "confirmed",
                "created_at": "2023-01-01T00:00:00",
                "flight_id": "flt_123",
                "passenger": {
                    "first_name": "John",
                    "last_name": "Doe",
                    "email": "john@example.com",
                    "passport": "P12345678"
                },
                "extras": {"baggage": 1},
                "total_price": 500.0,
                "currency": "USD",
                "user_email": "john@example.com"
            }
            
            # Send GET request
            response = client.get("/trip/ABC123")
            
            # Verify response
            assert response.status_code == 200
            data = response.json()
            assert data["id"] == "booking_123"
            assert data["pnr"] == "ABC123"
            assert data["status"] == "confirmed"
            
            # Verify booking manager was called
            mock_booking_manager.get_booking_by_pnr.assert_called_once_with("ABC123")

if __name__ == "__main__":
    pytest.main([__file__])