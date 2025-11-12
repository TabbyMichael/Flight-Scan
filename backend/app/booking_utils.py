import json
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime
import uuid
from .postgres_db import PostgresDatabaseManager

class BookingManager:
    def __init__(self, data_dir: str = "data"):
        self.base_dir = Path(__file__).parent.parent
        self.data_dir = self.base_dir / data_dir
        self.db = PostgresDatabaseManager()
    
    def create_booking(self, booking_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new booking"""
        # Generate booking ID and PNR if not provided
        if 'id' not in booking_data:
            booking_data['id'] = str(uuid.uuid4())
        if 'pnr' not in booking_data:
            booking_data['pnr'] = ''.join(str(uuid.uuid4().int)[:6]).upper()
        if 'status' not in booking_data:
            booking_data['status'] = 'confirmed'
        if 'created_at' not in booking_data:
            booking_data['created_at'] = datetime.utcnow().isoformat()
        if 'currency' not in booking_data:
            booking_data['currency'] = 'USD'
        
        # Add user email from passenger info
        booking_data['user_email'] = booking_data['passenger']['email']
        
        # Create booking in database
        return self.db.create_booking(booking_data)
    
    def get_user_bookings(self, email: str) -> List[Dict[str, Any]]:
        """Get all bookings for a user"""
        return self.db.get_bookings_by_user_email(email)
    
    def get_booking_by_pnr(self, pnr: str) -> Optional[Dict[str, Any]]:
        """Get booking by PNR"""
        return self.db.get_booking_by_pnr(pnr)