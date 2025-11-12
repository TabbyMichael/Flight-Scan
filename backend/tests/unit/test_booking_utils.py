import pytest
from unittest.mock import patch, MagicMock
from app.booking_utils import BookingManager
from datetime import datetime

class TestBookingManager:
    """Test cases for BookingManager class"""
    
    @patch('app.booking_utils.PostgresDatabaseManager')
    def test_init(self, mock_db_manager):
        """Test BookingManager initialization"""
        # Create BookingManager instance
        booking_manager = BookingManager()
        
        # Verify PostgresDatabaseManager was instantiated
        mock_db_manager.assert_called_once()
        assert hasattr(booking_manager, 'db')
    
    @patch('app.booking_utils.PostgresDatabaseManager')
    def test_create_booking_adds_missing_fields(self, mock_db_manager):
        """Test that create_booking adds missing fields"""
        # Setup mock
        mock_db = MagicMock()
        mock_db_manager.return_value = mock_db
        booking_manager = BookingManager()
        
        # Test data without optional fields
        booking_data = {
            'flight_id': 'flt_123',
            'passenger': {
                'first_name': 'John',
                'last_name': 'Doe',
                'email': 'john@example.com',
                'passport': 'P12345678'
            },
            'extras': {'baggage': 1},
            'total_price': 500.0
        }
        
        # Configure mock to return the input data
        mock_db.create_booking.return_value = booking_data
        
        # Call create_booking
        result = booking_manager.create_booking(booking_data)
        
        # Verify missing fields were added
        assert 'id' in result
        assert 'pnr' in result
        assert 'status' in result
        assert 'created_at' in result
        assert 'currency' in result
        assert 'user_email' in result
        
        # Verify default values
        assert result['status'] == 'confirmed'
        assert result['currency'] == 'USD'
        assert result['user_email'] == 'john@example.com'
        
        # Verify db.create_booking was called
        mock_db.create_booking.assert_called_once()

    @patch('app.booking_utils.PostgresDatabaseManager')
    def test_get_user_bookings(self, mock_db_manager):
        """Test get_user_bookings method"""
        # Setup mock
        mock_db = MagicMock()
        mock_db_manager.return_value = mock_db
        booking_manager = BookingManager()
        
        # Test data
        email = "test@example.com"
        
        # Call method
        booking_manager.get_user_bookings(email)
        
        # Verify db method was called
        mock_db.get_bookings_by_user_email.assert_called_once_with(email)

    @patch('app.booking_utils.PostgresDatabaseManager')
    def test_get_booking_by_pnr(self, mock_db_manager):
        """Test get_booking_by_pnr method"""
        # Setup mock
        mock_db = MagicMock()
        mock_db_manager.return_value = mock_db
        booking_manager = BookingManager()
        
        # Test data
        pnr = "ABC123"
        
        # Call method
        booking_manager.get_booking_by_pnr(pnr)
        
        # Verify db method was called
        mock_db.get_booking_by_pnr.assert_called_once_with(pnr)

if __name__ == "__main__":
    pytest.main([__file__])