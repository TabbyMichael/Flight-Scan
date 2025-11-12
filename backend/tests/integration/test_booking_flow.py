import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.booking_utils import BookingManager

client = TestClient(app)

def test_complete_booking_flow():
    """Test the complete booking flow from search to retrieval"""
    # Step 1: Search for flights
    search_payload = {
        "origin": "RTM",
        "destination": "STN",
        "departure_date": "2025-12-21",
        "passengers": 2
    }
    
    search_response = client.post("/flights/search", json=search_payload)
    assert search_response.status_code == 200
    search_data = search_response.json()
    assert len(search_data["flights"]) > 0
    
    # Get the first flight for booking
    flight = search_data["flights"][0]
    flight_id = flight["id"]
    
    # Step 2: Create a booking
    booking_payload = {
        "flight_id": flight_id,
        "passenger": {
            "first_name": "Alice",
            "last_name": "Cooper",
            "email": "alice.cooper@example.com",
            "passport": "P12345678"
        },
        "extras": {"baggage": 1},
        "total_price": flight["price"],
        "currency": flight["currency"]
    }
    
    booking_response = client.post("/bookings", json=booking_payload)
    assert booking_response.status_code == 200
    booking_data = booking_response.json()
    
    # Verify booking structure
    assert "pnr" in booking_data
    assert "id" in booking_data
    assert booking_data["status"] == "confirmed"
    assert booking_data["flight_id"] == flight_id
    
    # Step 3: Retrieve booking by PNR
    pnr = booking_data["pnr"]
    retrieval_response = client.get(f"/trip/{pnr}")
    assert retrieval_response.status_code == 200
    retrieved_booking = retrieval_response.json()
    
    # Verify retrieved booking matches created booking
    assert retrieved_booking["pnr"] == pnr
    assert retrieved_booking["flight_id"] == flight_id
    assert retrieved_booking["passenger"]["email"] == "alice.cooper@example.com"

def test_user_bookings_retrieval():
    """Test retrieving all bookings for a user"""
    # Create multiple bookings for the same user
    user_email = "multi.booker@example.com"
    
    # First booking
    booking1_payload = {
        "flight_id": "flt_100",
        "passenger": {
            "first_name": "Multi",
            "last_name": "Booker",
            "email": user_email,
            "passport": "P11111111"
        },
        "extras": {},
        "total_price": 500.00,
        "currency": "USD"
    }
    
    client.post("/bookings", json=booking1_payload)
    
    # Second booking
    booking2_payload = {
        "flight_id": "flt_200",
        "passenger": {
            "first_name": "Multi",
            "last_name": "Booker",
            "email": user_email,
            "passport": "P11111111"
        },
        "extras": {"baggage": 2},
        "total_price": 750.00,
        "currency": "USD"
    }
    
    client.post("/bookings", json=booking2_payload)
    
    # Retrieve all bookings for the user
    response = client.get(f"/bookings?email={user_email}")
    assert response.status_code == 200
    bookings = response.json()
    
    # Should have at least 2 bookings for this user
    assert len(bookings) >= 2
    
    # Verify all bookings belong to the user
    for booking in bookings:
        assert booking["passenger"]["email"] == user_email