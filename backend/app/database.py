import sqlite3
import json
import os
from pathlib import Path
from typing import List, Dict, Any, Optional
from datetime import datetime

class DatabaseManager:
    def __init__(self, db_path: str = "data/skyscan.db"):
        self.db_path = db_path
        self._init_db()
    
    def _init_db(self):
        """Initialize the database and create tables if they don't exist"""
        # Create data directory if it doesn't exist
        Path(self.db_path).parent.mkdir(parents=True, exist_ok=True)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create users table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
        ''')
        
        # Create bookings table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS bookings (
                id TEXT PRIMARY KEY,
                pnr TEXT UNIQUE NOT NULL,
                status TEXT NOT NULL,
                created_at TEXT NOT NULL,
                flight_id TEXT NOT NULL,
                passenger_data TEXT NOT NULL,  -- JSON string
                extras_data TEXT NOT NULL,      -- JSON string
                total_price REAL NOT NULL,
                currency TEXT NOT NULL,
                user_email TEXT NOT NULL,
                FOREIGN KEY (user_email) REFERENCES users(email)
            )
        ''')
        
        # Create flights table (for caching flight data)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS flights (
                id TEXT PRIMARY KEY,
                airline_code TEXT,
                flight_number TEXT,
                departure_airport TEXT,
                arrival_airport TEXT,
                departure_time TEXT,
                arrival_time TEXT,
                duration INTEGER,
                price REAL,
                stops INTEGER,
                currency TEXT,
                segments_data TEXT,  -- JSON string
                cabin_class TEXT
            )
        ''')
        
        conn.commit()
        conn.close()
    
    # User methods
    def create_user(self, user_data: Dict[str, Any]) -> bool:
        """Create a new user"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO users (id, first_name, last_name, email, password_hash, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (
                user_data['id'],
                user_data['first_name'],
                user_data['last_name'],
                user_data['email'],
                user_data['password_hash'],
                user_data['created_at']
            ))
            
            conn.commit()
            conn.close()
            return True
        except sqlite3.IntegrityError:
            # User with this email already exists
            return False
        except Exception:
            return False
    
    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get user by email"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM users WHERE email = ?', (email,))
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return dict(row)
        return None
    
    def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user by ID"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM users WHERE id = ?', (user_id,))
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return dict(row)
        return None
    
    # Booking methods
    def create_booking(self, booking_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new booking"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Convert dict fields to JSON strings
        passenger_data = json.dumps(booking_data['passenger'])
        extras_data = json.dumps(booking_data['extras'])
        
        cursor.execute('''
            INSERT INTO bookings (
                id, pnr, status, created_at, flight_id, 
                passenger_data, extras_data, total_price, currency, user_email
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            booking_data['id'],
            booking_data['pnr'],
            booking_data['status'],
            booking_data['created_at'],
            booking_data['flight_id'],
            passenger_data,
            extras_data,
            booking_data['total_price'],
            booking_data['currency'],
            booking_data['user_email']
        ))
        
        conn.commit()
        conn.close()
        
        return booking_data
    
    def get_bookings_by_user_email(self, email: str) -> List[Dict[str, Any]]:
        """Get all bookings for a user"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM bookings WHERE user_email = ?', (email,))
        rows = cursor.fetchall()
        conn.close()
        
        bookings = []
        for row in rows:
            booking = dict(row)
            # Convert JSON strings back to dicts
            booking['passenger'] = json.loads(booking['passenger_data'])
            booking['extras'] = json.loads(booking['extras_data'])
            # Remove the JSON string fields
            del booking['passenger_data']
            del booking['extras_data']
            bookings.append(booking)
        
        return bookings
    
    def get_booking_by_pnr(self, pnr: str) -> Optional[Dict[str, Any]]:
        """Get booking by PNR"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM bookings WHERE pnr = ?', (pnr,))
        row = cursor.fetchone()
        conn.close()
        
        if row:
            booking = dict(row)
            # Convert JSON strings back to dicts
            booking['passenger'] = json.loads(booking['passenger_data'])
            booking['extras'] = json.loads(booking['extras_data'])
            # Remove the JSON string fields
            del booking['passenger_data']
            del booking['extras_data']
            return booking
        return None
    
    # Flight methods (optional caching)
    def cache_flights(self, flights_data: List[Dict[str, Any]]) -> None:
        """Cache flight data in the database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Clear existing flights
        cursor.execute('DELETE FROM flights')
        
        # Insert new flights
        for flight in flights_data:
            segments_data = json.dumps(flight.get('segments', []))
            
            cursor.execute('''
                INSERT OR REPLACE INTO flights (
                    id, airline_code, flight_number, departure_airport, arrival_airport,
                    departure_time, arrival_time, duration, price, stops, currency, 
                    segments_data, cabin_class
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                flight['id'],
                flight.get('airlineCode'),
                flight.get('flightNumber'),
                flight.get('departureAirport'),
                flight.get('arrivalAirport'),
                flight.get('departureTime'),
                flight.get('arrivalTime'),
                flight.get('duration', 0),
                flight.get('price', 0.0),
                flight.get('stops', 0),
                flight.get('currency', 'USD'),
                segments_data,
                flight.get('cabinClass', '')
            ))
        
        conn.commit()
        conn.close()
    
    def get_cached_flights(self) -> List[Dict[str, Any]]:
        """Get cached flight data from the database"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM flights')
        rows = cursor.fetchall()
        conn.close()
        
        flights = []
        for row in rows:
            flight = dict(row)
            # Convert JSON strings back to lists/dicts
            flight['segments'] = json.loads(flight['segments_data'])
            del flight['segments_data']
            flights.append(flight)
        
        return flights