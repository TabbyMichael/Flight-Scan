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
from .postgres_db import PostgresDatabaseManager
from .validation import validate_booking_request, validate_user_registration, sanitize_input
from .security import create_access_token, decode_access_token, hash_password, verify_password
import hashlib
import secrets

# Initialize services
booking_manager = BookingManager()
database_manager = PostgresDatabaseManager()

# Initialize FastAPI app
app = FastAPI(
    title="SkyScan Flight API",
    description="Backend API for SkyScan Flight Search and Booking Management",
    version="1.0.0"
)

# CORS middleware - More secure configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:8080"],  # Specific origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],  # Specific methods
    allow_headers=["Authorization", "Content-Type"],  # Specific headers
    expose_headers=["Content-Disposition"],
    max_age=600,  # Cache preflight requests for 10 minutes
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

# Pydantic models for authentication
class UserRegistration(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: str
    first_name: str
    last_name: str
    email: EmailStr
    created_at: str

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
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Flight data file not found")
    except KeyError as e:
        raise HTTPException(status_code=500, detail=f"Invalid flight data format: missing key {str(e)}")
    except ValueError as e:
        raise HTTPException(status_code=500, detail=f"Invalid flight data format: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load flights: {str(e)}")

def parse_flight_dates(flight_data: Dict[str, Any]) -> tuple[datetime, datetime]:
    """Extract departure and arrival datetimes from flight data"""
    segments = flight_data.get("FareItinerary", {}).get("AirItinerary", {}).get(
        "OriginDestinationOptions", {}).get("OriginDestinationOption", [{}])[0].get("FlightSegment", [])
    
    if not segments:
        return datetime.now(), datetime.now()
        
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
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Flight data file not found")
    except KeyError as e:
        raise HTTPException(status_code=500, detail=f"Invalid flight data format: missing key {str(e)}")
    except ValueError as e:
        raise HTTPException(status_code=500, detail=f"Invalid flight data format: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to search flights: {str(e)}")

@app.get("/airports")
async def get_airports():
    """Return unique list of all airports from flights data"""
    try:
        flights = load_json_data("flights.json")
        airports = set()
        
        for item in flights.get("AirSearchResponse", {}).get("AirSearchResult", {}).get("FareItineraries", []):
            for segment in item.get("FareItinerary", {}).get("AirItinerary", {}).get("OriginDestinationOptions", {}).get("OriginDestinationOption", [{}])[0].get("FlightSegment", []):
                airports.add(segment.get("DepartureAirport", {}).get("LocationCode"))
                airports.add(segment.get("ArrivalAirport", {}).get("LocationCode"))
        
        return sorted([a for a in airports if a])  # Remove None and sort
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Flight data file not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load airports: {str(e)}")

@app.get("/airlines")
async def get_airlines():
    """Return list of airlines"""
    try:
        return load_json_data("airlines.json")
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Airlines data file not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load airlines: {str(e)}")

@app.get("/services")
async def get_services():
    try:
        return load_json_data("extra-services.json")
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Services data file not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load services: {str(e)}")

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
        raise HTTPException(status_code=500, detail=f"Failed to retrieve booking: {str(e)}")

@app.post("/bookings", response_model=BookingResponse)
async def create_booking(booking_request: CreateBookingRequest):
    """Create a new booking"""
    try:
        # Sanitize inputs
        sanitized_first_name = sanitize_input(booking_request.passenger.first_name)
        sanitized_last_name = sanitize_input(booking_request.passenger.last_name)
        sanitized_email = sanitize_input(booking_request.passenger.email)
        sanitized_passport = sanitize_input(booking_request.passenger.passport)
        
        # Validate booking request
        validate_booking_request(
            flight_id=booking_request.flight_id,
            first_name=sanitized_first_name,
            last_name=sanitized_last_name,
            email=sanitized_email,
            passport=sanitized_passport,
            total_price=booking_request.total_price
        )
        
        booking_data = {
            "flight_id": booking_request.flight_id,
            "passenger": {
                "first_name": sanitized_first_name,
                "last_name": sanitized_last_name,
                "email": sanitized_email,
                "passport": sanitized_passport
            },
            "passenger_email": sanitized_email,
            "extras": booking_request.extras,
            "total_price": booking_request.total_price,
            "currency": booking_request.currency,
        }
        
        booking = booking_manager.create_booking(booking_data)
        return booking
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create booking: {str(e)}")

@app.get("/bookings", response_model=List[BookingResponse])
async def get_user_bookings(email: str = Query(..., description="User's email address")):
    """Get all bookings for a user"""
    try:
        return booking_manager.get_user_bookings(email)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve bookings: {str(e)}")

@app.post("/auth/register", response_model=UserResponse)
async def register_user(user_data: UserRegistration):
    """Register a new user"""
    try:
        # Sanitize inputs
        sanitized_first_name = sanitize_input(user_data.first_name)
        sanitized_last_name = sanitize_input(user_data.last_name)
        sanitized_email = sanitize_input(user_data.email)
        
        # Validate user registration data
        validate_user_registration(
            first_name=sanitized_first_name,
            last_name=sanitized_last_name,
            email=sanitized_email,
            password=user_data.password
        )
        
        # Check if user already exists
        existing_user = database_manager.get_user_by_email(sanitized_email)
        if existing_user:
            raise HTTPException(status_code=400, detail="User with this email already exists")
        
        # Create new user
        user_id = str(uuid4())
        new_user = {
            "id": user_id,
            "first_name": sanitized_first_name,
            "last_name": sanitized_last_name,
            "email": sanitized_email,
            "password_hash": hash_password(user_data.password),
            "created_at": datetime.utcnow().isoformat()
        }
        
        # Save user to database
        success = database_manager.create_user(new_user)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to create user")
        
        return UserResponse(
            id=user_id,
            first_name=sanitized_first_name,
            last_name=sanitized_last_name,
            email=sanitized_email,
            created_at=new_user["created_at"]
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to register user: {str(e)}")

@app.post("/auth/login")
async def login_user(credentials: UserLogin):
    """Login user and return JWT token"""
    try:
        # Find user
        user = database_manager.get_user_by_email(credentials.email)
        
        if not user:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Verify password
        if not verify_password(user["password_hash"], credentials.password):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Create JWT token
        access_token = create_access_token(
            data={
                "user_id": user["id"],
                "email": user["email"],
                "first_name": user["first_name"],
                "last_name": user["last_name"]
            }
        )
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user["id"],
                "email": user["email"],
                "first_name": user["first_name"],
                "last_name": user["last_name"]
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to login user: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
