import pytest
from datetime import datetime
from app.main import parse_flight_dates

def test_parse_flight_dates_valid():
    """Test parsing valid flight dates"""
    flight_data = {
        "FareItinerary": {
            "AirItinerary": {
                "OriginDestinationOptions": {
                    "OriginDestinationOption": [{
                        "FlightSegment": [{
                            "DepartureDateTime": "2025-12-21T12:55:00",
                            "DepartureTimeZone": {"GMTOffset": "+01:00"},
                            "ArrivalDateTime": "2025-12-21T12:50:00",
                            "ArrivalTimeZone": {"GMTOffset": "+00:00"}
                        }]
                    }]
                }
            }
        }
    }
    
    dep_time, arr_time = parse_flight_dates(flight_data)
    # Now it should return valid datetime objects
    assert isinstance(dep_time, datetime)
    assert isinstance(arr_time, datetime)
    assert dep_time.year == 2025
    assert dep_time.month == 12
    assert dep_time.day == 21

def test_parse_flight_dates_invalid():
    """Test parsing invalid flight data"""
    flight_data = {}
    dep_time, arr_time = parse_flight_dates(flight_data)
    assert dep_time is None
    assert arr_time is None

def test_parse_flight_dates_empty_segments():
    """Test parsing flight data with empty segments"""
    flight_data = {
        "FareItinerary": {
            "AirItinerary": {
                "OriginDestinationOptions": {
                    "OriginDestinationOption": [{}]
                }
            }
        }
    }
    dep_time, arr_time = parse_flight_dates(flight_data)
    assert dep_time is None
    assert arr_time is None