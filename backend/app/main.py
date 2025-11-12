from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import json
import os
from pathlib import Path
from datetime import datetime, date, timedelta
from pydantic import BaseModel, EmailStr, Field
from uuid import UUID, uuid4
from .booking_utils import BookingManager

# Initialize services
booking_manager = BookingManager()

# Initialize FastAPI app
app = FastAPI(
    title="SkyScan Flight API",
    description="Backend API for SkyScan Flight Search and Booking Management",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load data files
def load_json_data(filename: str) -> Any:
    base_dir = Path(__file__).parent.parent
    data_path = base_dir / "data" / filename
    with open(data_path, 'r') as f:
        return json.load(f)

# Pydantic models
class FlightSearch(BaseModel):
    origin: Optional[str] = None
    destination: Optional[str] = None
    departure_date: Optional[date] = None
    return_date: Optional[date] = None
    passengers: int = 1
    max_price: Optional[float] = None
    max_stops: Optional[int] = None
    airline_codes: Optional[List[str]] = None

class PassengerInfo(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    passport: str

class CreateBookingRequest(BaseModel):
    flight_id: str
    passenger: PassengerInfo
    extras: Dict[str, int] = Field(default_factory=dict)
    total_price: float
    currency: str = "USD"

class BookingResponse(BaseModel):
    id: str
    pnr: str
    status: str
    created_at: str
    flight_id: str
    passenger: PassengerInfo
    extras: Dict[str, int]
    total_price: float
    currency: str

# Routes
@app.get("/")
async def root():
    return {"message": "Welcome to SkyScan Flight API"}

@app.get("/flights")
async def get_flights():
    """Return simplified list of flights the mobile app expects."""
    try:
        raw = load_json_data("flights.json")
        fare_itineraries = (
            raw.get("AirSearchResponse", {})
               .get("AirSearchResult", {})
               .get("FareItineraries", [])
        )
        simplified: list[dict] = []

        for idx, item in enumerate(fare_itineraries):
            itin = item.get("FareItinerary", {})
            # price & currency
            total_fare = itin.get("AirItineraryFareInfo", {}) \
                               .get("ItinTotalFares", {}) \
                               .get("TotalFare", {})
            price = float(total_fare.get("Amount", 0))
            currency = total_fare.get("CurrencyCode", "USD")

            # segments & basic details – flatten first flight segment
            od_options = itin.get("OriginDestinationOptions", [])
            if not od_options:
                continue
            flight_seg = od_options[0].get("OriginDestinationOption", [])[0] \
                                      .get("FlightSegment", {})

            dep_airport = flight_seg.get("DepartureAirportLocationCode", "")
            arr_airport = flight_seg.get("ArrivalAirportLocationCode", "")
            dep_time = flight_seg.get("DepartureDateTime", "")
            arr_time = flight_seg.get("ArrivalDateTime", "")
            flight_number = flight_seg.get("FlightNumber", "")
            airline_code = flight_seg.get("MarketingAirlineCode", "")
            duration = int(flight_seg.get("JourneyDuration", 0))
            stops = od_options[0].get("TotalStops", 0)

            # Build simplified segment list (only one segment for now)
            segment = {
                "departureAirport": dep_airport,
                "arrivalAirport": arr_airport,
                "departureTime": dep_time,
                "arrivalTime": arr_time,
                "flightNumber": flight_number,
                "airlineCode": airline_code,
                "duration": duration,
            }

            simplified.append({
                "id": f"flt_{idx}",
                "airlineCode": airline_code,
                "flightNumber": flight_number,
                "departureAirport": dep_airport,
                "arrivalAirport": arr_airport,
                "departureTime": dep_time,
                "arrivalTime": arr_time,
                "duration": duration,
                "price": price,
                "stops": stops,
                "currency": currency,
                "segments": [segment],
            })

        return {"flights": simplified}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def parse_flight_dates(flight_data: Dict[str, Any]) -> tuple[datetime, datetime]:
    """Extract departure and arrival datetimes from flight data"""
    segments = flight_data.get("FareItinerary", {}).get("AirItinerary", {}).get(
        "OriginDestinationOptions", {}).get("OriginDestinationOption", [{}])[0].get("FlightSegment", [])
    
    if not segments:
        return None, None
        
    first_segment = segments[0]
    last_segment = segments[-1]
    
    dep_time = datetime.strptime(
        f"{first_segment.get('DepartureDateTime')} {first_segment.get('DepartureTimeZone', {}).get('GMTOffset', '+00:00')}",
        "%Y-%m-%dT%H:%M %z"
    )
    
    arr_time = datetime.strptime(
        f"{last_segment.get('ArrivalDateTime')} {last_segment.get('ArrivalTimeZone', {}).get('GMTOffset', '+00:00')}",
        "%Y-%m-%dT%H:%M %z"
    )
    
    return dep_time, arr_time

@app.post("/flights/search")
async def search_flights(search: FlightSearch):
    """Search flights with advanced filtering"""
    try:
        flights_data = load_json_data("flights.json")
        fare_itineraries = flights_data.get("AirSearchResponse", {}).get("AirSearchResult", {}).get("FareItineraries", [])
        
        filtered_flights = []
        
        for idx, item in enumerate(fare_itineraries):
            itin = item.get("FareItinerary", {})
            
            # Extract price & currency
            total_fare = itin.get("AirItineraryFareInfo", {}).get("ItinTotalFares", {}).get("TotalFare", {})
            price = float(total_fare.get("Amount", 0))
            currency = total_fare.get("CurrencyCode", "USD")
            
            # Extract flight segments
            od_options = itin.get("OriginDestinationOptions", [])
            if not od_options:
                continue
                
            flight_seg = od_options[0].get("OriginDestinationOption", [])[0].get("FlightSegment", {})
            
            dep_airport = flight_seg.get("DepartureAirportLocationCode", "")
            arr_airport = flight_seg.get("ArrivalAirportLocationCode", "")
            dep_time = flight_seg.get("DepartureDateTime", "")
            arr_time = flight_seg.get("ArrivalDateTime", "")
            flight_number = flight_seg.get("FlightNumber", "")
            airline_code = flight_seg.get("MarketingAirlineCode", "")
            airline_name = flight_seg.get("MarketingAirlineName", "")
            duration = int(flight_seg.get("JourneyDuration", 0))
            stops = od_options[0].get("TotalStops", 0)
            cabin_class = flight_seg.get("CabinClassText", "")
            
            # Apply filters
            # Max price filter
            if search.max_price is not None and price > search.max_price:
                continue
                
            # Max stops filter
            if search.max_stops is not None and stops > search.max_stops:
                continue
                
            # Airline codes filter
            if search.airline_codes and airline_code not in search.airline_codes:
                continue
                
            # Origin filter
            if search.origin and dep_airport.upper() != search.origin.upper():
                continue
                
            # Destination filter
            if search.destination and arr_airport.upper() != search.destination.upper():
                continue
                
            # Departure date filter
            if search.departure_date:
                try:
                    dep_date = datetime.fromisoformat(dep_time.replace("Z", "+00:00")).date()
                    if dep_date != search.departure_date:
                        continue
                except:
                    pass  # If we can't parse the date, we skip the filter
            
            # Build simplified segment list
            segment = {
                "departureAirport": dep_airport,
                "arrivalAirport": arr_airport,
                "departureTime": dep_time,
                "arrivalTime": arr_time,
                "flightNumber": flight_number,
                "airlineCode": airline_code,
                "airlineName": airline_name,
                "duration": duration,
            }
            
            # Add flight to results
            filtered_flights.append({
                "id": f"flt_{idx}",
                "airlineCode": airline_code,
                "airlineName": airline_name,
                "flightNumber": flight_number,
                "departureAirport": dep_airport,
                "arrivalAirport": arr_airport,
                "departureTime": dep_time,
                "arrivalTime": arr_time,
                "duration": duration,
                "price": price,
                "stops": stops,
                "currency": currency,
                "cabinClass": cabin_class,
                "segments": [segment],
            })
            
        return {"flights": filtered_flights}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/airports")
async def get_airports():
    """Return unique list of all airports from flights data"""
    flights = load_json_data("flights.json")
    airports = set()
    
    for item in flights.get("AirSearchResponse", {}).get("AirSearchResult", {}).get("FareItineraries", []):
        for segment in item.get("FareItinerary", {}).get("AirItinerary", {}).get("OriginDestinationOptions", {}).get("OriginDestinationOption", [{}])[0].get("FlightSegment", []):
            airports.add(segment.get("DepartureAirport", {}).get("LocationCode"))
            airports.add(segment.get("ArrivalAirport", {}).get("LocationCode"))
    
    return sorted([a for a in airports if a])  # Remove None and sort

@app.get("/airlines")
async def get_airlines():
    """Return list of airlines"""
    return load_json_data("airline-list.json")

@app.get("/services")
async def get_services():
    try:
        return load_json_data("extra-services.json")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/trip/{pnr}", response_model=BookingResponse)
async def get_trip_details(pnr: str):
    """Get trip details by PNR"""
    try:
        booking = booking_manager.get_booking_by_pnr(pnr)
        if not booking:
            raise HTTPException(status_code=404, detail="Booking not found")
        return booking
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/bookings", response_model=BookingResponse)
async def create_booking(booking_request: CreateBookingRequest):
    """Create a new booking"""
    try:
        booking_data = {
            "flight_id": booking_request.flight_id,
            "passenger": booking_request.passenger.dict(),
            "passenger_email": booking_request.passenger.email,
            "extras": booking_request.extras,
            "total_price": booking_request.total_price,
            "currency": booking_request.currency,
        }
        
        booking = booking_manager.create_booking(booking_data)
        return booking
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/bookings", response_model=List[BookingResponse])
async def get_user_bookings(email: str = Query(..., description="User's email address")):
    """Get all bookings for a user"""
    try:
        return booking_manager.get_user_bookings(email)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
