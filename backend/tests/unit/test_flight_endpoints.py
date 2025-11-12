import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.booking_utils import BookingManager
import json
import os
from pathlib import Path

# Create a test client
client = TestClient(app)

def test_get_flights():
    """Test retrieving all flights"""
    response = client.get("/flights")
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data
    assert len(data["flights"]) > 0
    # Verify required fields are present
    flight = data["flights"][0]
    assert "id" in flight
    assert "airlineCode" in flight
    assert "price" in flight
    assert "departureAirport" in flight
    assert "arrivalAirport" in flight

def test_search_flights_by_price():
    """Test searching flights with price filter"""
    search_data = {
        "max_price": 600.0
    }
    response = client.post("/flights/search", json=search_data)
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data
    # Verify all returned flights are under max_price
    for flight in data["flights"]:
        assert flight["price"] <= 600.0

def test_search_flights_invalid_data():
    """Test searching flights with invalid data"""
    search_data = {
        "max_price": "invalid"
    }
    response = client.post("/flights/search", json=search_data)
    # Should return 422 for validation error
    assert response.status_code == 422

def test_get_airports():
    """Test retrieving unique airports"""
    response = client.get("/airports")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    # Should have some airports since we have flight data
    assert len(data) > 0
    # All airports should be strings
    for airport in data:
        assert isinstance(airport, str)

def test_get_airlines():
    """Test retrieving airlines"""
    response = client.get("/airlines")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    # Should have some airlines
    assert len(data) > 0

def test_get_services():
    """Test retrieving extra services"""
    response = client.get("/services")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list) or isinstance(data, dict)