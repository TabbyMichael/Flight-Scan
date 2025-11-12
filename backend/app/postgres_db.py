import json
import os
from typing import List, Dict, Any, Optional
from datetime import datetime
from sqlalchemy import create_engine, Column, String, Integer, Float, DateTime, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.dialects.postgresql import JSONB

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    
    id = Column(String, primary_key=True)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    created_at = Column(String, nullable=False)

class Booking(Base):
    __tablename__ = 'bookings'
    
    id = Column(String, primary_key=True)
    pnr = Column(String, unique=True, nullable=False)
    status = Column(String, nullable=False)
    created_at = Column(String, nullable=False)
    flight_id = Column(String, nullable=False)
    passenger_data = Column(JSONB, nullable=False)
    extras_data = Column(JSONB, nullable=False)
    total_price = Column(Float, nullable=False)
    currency = Column(String, nullable=False)
    user_email = Column(String, ForeignKey('users.email'), nullable=False)
    
    user = relationship("User", back_populates="bookings")

User.bookings = relationship("Booking", back_populates="user")

class Flight(Base):
    __tablename__ = 'flights'
    
    id = Column(String, primary_key=True)
    airline_code = Column(String)
    airline_name = Column(String)
    flight_number = Column(String)
    departure_airport = Column(String)
    arrival_airport = Column(String)
    departure_time = Column(String)
    arrival_time = Column(String)
    duration = Column(Integer)
    price = Column(Float)
    stops = Column(Integer)
    currency = Column(String)
    segments_data = Column(JSONB)
    cabin_class = Column(String)

class ExtraService(Base):
    __tablename__ = 'extra_services'
    
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(String)
    price = Column(Float, nullable=False)
    min_quantity = Column(Integer, nullable=False)
    max_quantity = Column(Integer, nullable=False)
    is_mandatory = Column(Boolean, nullable=False)

class PostgresDatabaseManager:
    def __init__(self, database_url: Optional[str] = None):
        if database_url is None:
            # Default to localhost with default PostgreSQL credentials
            database_url = os.environ.get(
                "DATABASE_URL", 
                "postgresql://skyscan_user:skyscan_pass@localhost:5432/skyscan_db"
            )
        
        self.engine = create_engine(database_url, echo=False)
        self.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)
        self._init_db()
    
    def _init_db(self):
        """Initialize the database and create tables if they don't exist"""
        Base.metadata.create_all(bind=self.engine)
    
    def get_session(self):
        """Get a database session"""
        return self.SessionLocal()
    
    # User methods
    def create_user(self, user_data: Dict[str, Any]) -> bool:
        """Create a new user"""
        session = self.get_session()
        try:
            user = User(
                id=user_data['id'],
                first_name=user_data['first_name'],
                last_name=user_data['last_name'],
                email=user_data['email'],
                password_hash=user_data['password_hash'],
                created_at=user_data['created_at']
            )
            session.add(user)
            session.commit()
            return True
        except Exception as e:
            session.rollback()
            # Check if it's a duplicate email error
            if 'duplicate key value violates unique constraint' in str(e):
                return False
            raise e
        finally:
            session.close()
    
    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get user by email"""
        session = self.get_session()
        try:
            user = session.query(User).filter(User.email == email).first()
            if user:
                return {
                    'id': user.id,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                    'email': user.email,
                    'password_hash': user.password_hash,
                    'created_at': user.created_at
                }
            return None
        finally:
            session.close()
    
    def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user by ID"""
        session = self.get_session()
        try:
            user = session.query(User).filter(User.id == user_id).first()
            if user:
                return {
                    'id': user.id,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                    'email': user.email,
                    'password_hash': user.password_hash,
                    'created_at': user.created_at
                }
            return None
        finally:
            session.close()
    
    # Booking methods
    def create_booking(self, booking_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new booking"""
        session = self.get_session()
        try:
            booking = Booking(
                id=booking_data['id'],
                pnr=booking_data['pnr'],
                status=booking_data['status'],
                created_at=booking_data['created_at'],
                flight_id=booking_data['flight_id'],
                passenger_data=booking_data['passenger'],
                extras_data=booking_data['extras'],
                total_price=booking_data['total_price'],
                currency=booking_data['currency'],
                user_email=booking_data['user_email']
            )
            session.add(booking)
            session.commit()
            return booking_data
        finally:
            session.close()
    
    def get_bookings_by_user_email(self, email: str) -> List[Dict[str, Any]]:
        """Get all bookings for a user"""
        session = self.get_session()
        try:
            bookings = session.query(Booking).filter(Booking.user_email == email).all()
            result = []
            for booking in bookings:
                result.append({
                    'id': booking.id,
                    'pnr': booking.pnr,
                    'status': booking.status,
                    'created_at': booking.created_at,
                    'flight_id': booking.flight_id,
                    'passenger': booking.passenger_data,
                    'extras': booking.extras_data,
                    'total_price': booking.total_price,
                    'currency': booking.currency,
                    'user_email': booking.user_email
                })
            return result
        finally:
            session.close()
    
    def get_booking_by_pnr(self, pnr: str) -> Optional[Dict[str, Any]]:
        """Get booking by PNR"""
        session = self.get_session()
        try:
            booking = session.query(Booking).filter(Booking.pnr == pnr).first()
            if booking:
                return {
                    'id': booking.id,
                    'pnr': booking.pnr,
                    'status': booking.status,
                    'created_at': booking.created_at,
                    'flight_id': booking.flight_id,
                    'passenger': booking.passenger_data,
                    'extras': booking.extras_data,
                    'total_price': booking.total_price,
                    'currency': booking.currency,
                    'user_email': booking.user_email
                }
            return None
        finally:
            session.close()
    
    # Flight methods (optional caching)
    def cache_flights(self, flights_data: List[Dict[str, Any]]) -> None:
        """Cache flight data in the database"""
        session = self.get_session()
        try:
            # Clear existing flights
            session.query(Flight).delete()
            
            # Insert new flights
            for flight in flights_data:
                db_flight = Flight(
                    id=flight['id'],
                    airline_code=flight.get('airlineCode'),
                    airline_name=flight.get('airlineName'),
                    flight_number=flight.get('flightNumber'),
                    departure_airport=flight.get('departureAirport'),
                    arrival_airport=flight.get('arrivalAirport'),
                    departure_time=flight.get('departureTime'),
                    arrival_time=flight.get('arrivalTime'),
                    duration=flight.get('duration', 0),
                    price=flight.get('price', 0.0),
                    stops=flight.get('stops', 0),
                    currency=flight.get('currency', 'USD'),
                    segments_data=flight.get('segments', []),
                    cabin_class=flight.get('cabinClass', '')
                )
                session.add(db_flight)
            
            session.commit()
        finally:
            session.close()
    
    def get_cached_flights(self) -> List[Dict[str, Any]]:
        """Get cached flight data from the database"""
        session = self.get_session()
        try:
            flights = session.query(Flight).all()
            result = []
            for flight in flights:
                result.append({
                    'id': flight.id,
                    'airlineCode': flight.airline_code,
                    'airlineName': flight.airline_name,
                    'flightNumber': flight.flight_number,
                    'departureAirport': flight.departure_airport,
                    'arrivalAirport': flight.arrival_airport,
                    'departureTime': flight.departure_time,
                    'arrivalTime': flight.arrival_time,
                    'duration': flight.duration,
                    'price': flight.price,
                    'stops': flight.stops,
                    'currency': flight.currency,
                    'segments': flight.segments_data,
                    'cabinClass': flight.cabin_class
                })
            return result
        finally:
            session.close()
    
    # Extra service methods
    def cache_extra_services(self, services_data: List[Dict[str, Any]]) -> None:
        """Cache extra services data in the database"""
        session = self.get_session()
        try:
            # Clear existing services
            session.query(ExtraService).delete()
            
            # Insert new services
            for service in services_data:
                db_service = ExtraService(
                    id=service['id'],
                    name=service['name'],
                    description=service.get('description', ''),
                    price=service['price'],
                    min_quantity=service['minQuantity'],
                    max_quantity=service['maxQuantity'],
                    is_mandatory=service['isMandatory']
                )
                session.add(db_service)
            
            session.commit()
        finally:
            session.close()
    
    def get_cached_extra_services(self) -> List[Dict[str, Any]]:
        """Get cached extra services data from the database"""
        session = self.get_session()
        try:
            services = session.query(ExtraService).all()
            result = []
            for service in services:
                result.append({
                    'id': service.id,
                    'name': service.name,
                    'description': service.description,
                    'price': service.price,
                    'minQuantity': service.min_quantity,
                    'maxQuantity': service.max_quantity,
                    'isMandatory': service.is_mandatory
                })
            return result
        finally:
            session.close()