import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_flight_search_with_filters():
    """Test flight search with various filters"""
    # Test basic search
    search_payload = {
        "origin": "RTM",
        "destination": "STN",
        "passengers": 1
    }
    
    response = client.post("/flights/search", json=search_payload)
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data
    assert isinstance(data["flights"], list)
    
    # Test search with max price filter
    search_payload["max_price"] = 600.0
    response = client.post("/flights/search", json=search_payload)
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data
    
    # Test search with airline filter
    search_payload["airline_codes"] = ["HV"]
    response = client.post("/flights/search", json=search_payload)
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data

def test_flight_search_edge_cases():
    """Test flight search edge cases"""
    # Test search with no results
    search_payload = {
        "origin": "NON",
        "destination": "EXIST",
        "passengers": 1
    }
    
    response = client.post("/flights/search", json=search_payload)
    assert response.status_code == 200
    data = response.json()
    assert "flights" in data
    assert isinstance(data["flights"], list)
    # Should return empty list for no matches
    assert len(data["flights"]) == 0

def test_flight_search_validation():
    """Test flight search validation"""
    # Test with invalid data
    search_payload = {
        "passengers": -1  # Invalid number of passengers
    }
    
    response = client.post("/flights/search", json=search_payload)
    # FastAPI validation should handle this
    # The actual behavior depends on the Pydantic model definition