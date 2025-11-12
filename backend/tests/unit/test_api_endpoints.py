import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_endpoint():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()

def test_get_flights():
    """Test getting all flights"""
    response = client.get("/flights")
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data
    # Check that we get a list of flights
    assert isinstance(data["flights"], list)

def test_get_airlines():
    """Test getting airlines"""
    response = client.get("/airlines")
    assert response.status_code == 200
    # Response should be a list
    data = response.json()
    assert isinstance(data, list)

def test_get_services():
    """Test getting extra services"""
    response = client.get("/services")
    assert response.status_code == 200
    # Response should be a dict with service categories
    data = response.json()
    assert isinstance(data, dict)
    # Should have the expected service categories
    assert "DynamicBaggage" in data
    assert "DynamicMeal" in data
    assert "DynamicSeat" in data

def test_search_flights():
    """Test searching flights"""
    search_payload = {
        "origin": "RTM",
        "destination": "STN",
        "passengers": 2
    }
    
    response = client.post("/flights/search", json=search_payload)
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data
    assert isinstance(data["flights"], list)

def test_create_booking():
    """Test creating a booking"""
    booking_payload = {
        "flight_id": "flt_0",
        "passenger": {
            "first_name": "Test",
            "last_name": "User",
            "email": "test@example.com",
            "passport": "P12345678"
        },
        "extras": {},
        "total_price": 557.86,
        "currency": "USD"
    }
    
    response = client.post("/bookings", json=booking_payload)
    assert response.status_code == 200
    data = response.json()
    
    # Check required fields are present
    required_fields = ["id", "pnr", "status", "flight_id", "passenger", "extras", "total_price", "currency"]
    for field in required_fields:
        assert field in data
        
    assert data["status"] == "confirmed"

def test_get_user_bookings():
    """Test getting user bookings"""
    # First create a booking
    booking_payload = {
        "flight_id": "flt_1",
        "passenger": {
            "first_name": "Jane",
            "last_name": "Smith",
            "email": "jane@example.com",
            "passport": "P87654321"
        },
        "extras": {"baggage": 2},
        "total_price": 738.98,
        "currency": "USD"
    }
    
    client.post("/bookings", json=booking_payload)
    
    # Then retrieve bookings for the user
    response = client.get("/bookings?email=jane@example.com")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_get_trip_details():
    """Test getting trip details by PNR"""
    # First create a booking to get a PNR
    booking_payload = {
        "flight_id": "flt_2",
        "passenger": {
            "first_name": "Bob",
            "last_name": "Johnson",
            "email": "bob@example.com",
            "passport": "P11223344"
        },
        "extras": {},
        "total_price": 865.75,
        "currency": "USD"
    }
    
    create_response = client.post("/bookings", json=booking_payload)
    assert create_response.status_code == 200
    booking_data = create_response.json()
    pnr = booking_data["pnr"]
    
    # Then retrieve the booking by PNR
    response = client.get(f"/trip/{pnr}")
    assert response.status_code == 200
    data = response.json()
    assert data["pnr"] == pnr