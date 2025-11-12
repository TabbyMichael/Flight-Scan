import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestFlightEndpoints:
    """Test suite for flight-related API endpoints"""
    
    def test_get_flights_success(self):
        """Test getting flights list"""
        response = client.get("/flights")
        assert response.status_code == 200
        
        data = response.json()
        assert "flights" in data
        assert isinstance(data["flights"], list)
        
        # Check that flights have required fields
        if len(data["flights"]) > 0:
            flight = data["flights"][0]
            assert "id" in flight
            assert "airlineCode" in flight
            assert "flightNumber" in flight
            assert "departureAirport" in flight
            assert "arrivalAirport" in flight
            assert "price" in flight
    
    def test_search_flights_success(self):
        """Test flight search functionality"""
        search_data = {
            "origin": "JFK",
            "destination": "LAX",
            "passengers": 1
        }
        
        response = client.post("/flights/search", json=search_data)
        assert response.status_code == 200
        
        data = response.json()
        assert "flights" in data
        assert isinstance(data["flights"], list)
    
    def test_search_flights_with_filters(self):
        """Test flight search with price and stops filters"""
        search_data = {
            "max_price": 500.0,
            "max_stops": 1,
            "passengers": 1
        }
        
        response = client.post("/flights/search", json=search_data)
        assert response.status_code == 200
        
        data = response.json()
        assert "flights" in data
    
    def test_get_airports_success(self):
        """Test getting airport list"""
        response = client.get("/airports")
        assert response.status_code == 200
        
        data = response.json()
        assert isinstance(data, list)
    
    def test_get_airlines_success(self):
        """Test getting airlines list"""
        response = client.get("/airlines")
        assert response.status_code == 200
        
        data = response.json()
        assert isinstance(data, list)
    
    def test_get_services_success(self):
        """Test getting extra services"""
        response = client.get("/services")
        assert response.status_code == 200
        
        data = response.json()
        assert isinstance(data, dict)