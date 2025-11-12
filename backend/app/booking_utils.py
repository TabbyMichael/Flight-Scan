import json
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime
import uuid

class BookingManager:
    def __init__(self, data_dir: str = "data"):
        self.base_dir = Path(__file__).parent.parent
        self.data_dir = self.base_dir / data_dir
        self.bookings_file = self.data_dir / "bookings.json"
        self._ensure_bookings_file()
    
    def _ensure_bookings_file(self):
        """Create bookings file if it doesn't exist"""
        self.data_dir.mkdir(exist_ok=True)
        if not self.bookings_file.exists():
            with open(self.bookings_file, 'w') as f:
                json.dump({"bookings": []}, f, indent=2)
    
    def _read_bookings(self) -> Dict[str, Any]:
        """Read all bookings from file"""
        with open(self.bookings_file, 'r') as f:
            return json.load(f)
    
    def _write_bookings(self, data: Dict[str, Any]):
        """Write bookings to file"""
        with open(self.bookings_file, 'w') as f:
            json.dump(data, f, indent=2)
    
    def create_booking(self, booking_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new booking"""
        bookings_data = self._read_bookings()
        
        # Generate booking ID and PNR
        booking_id = str(uuid.uuid4())
        pnr = ''.join(str(uuid.uuid4().int)[:6].upper())
        
        booking = {
            "id": booking_id,
            "pnr": pnr,
            "status": "confirmed",
            "created_at": datetime.utcnow().isoformat(),
            **booking_data
        }
        
        bookings_data["bookings"].append(booking)
        self._write_bookings(bookings_data)
        
        return booking
    
    def get_user_bookings(self, email: str) -> List[Dict[str, Any]]:
        """Get all bookings for a user"""
        bookings_data = self._read_bookings()
        return [
            b for b in bookings_data.get("bookings", [])
            if b.get("passenger_email", "").lower() == email.lower()
        ]
    
    def get_booking_by_pnr(self, pnr: str) -> Optional[Dict[str, Any]]:
        """Get booking by PNR"""
        bookings_data = self._read_bookings()
        for booking in bookings_data.get("bookings", []):
            if booking.get("pnr", "").lower() == pnr.lower():
                return booking
        return None
