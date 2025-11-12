import re
from typing import Optional
from .exception_handlers import SkyScanException

def validate_email(email: str) -> bool:
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_password(password: str) -> tuple[bool, Optional[str]]:
    """Validate password strength"""
    if len(password) < 6:
        return False, "Password must be at least 6 characters long"
    
    if len(password) > 128:
        return False, "Password must be less than 128 characters long"
    
    # Check for at least one uppercase letter
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least one uppercase letter"
    
    # Check for at least one lowercase letter
    if not re.search(r'[a-z]', password):
        return False, "Password must contain at least one lowercase letter"
    
    # Check for at least one digit
    if not re.search(r'\d', password):
        return False, "Password must contain at least one digit"
    
    return True, None

def validate_name(name: str) -> tuple[bool, Optional[str]]:
    """Validate name fields"""
    if not name or not name.strip():
        return False, "Name cannot be empty"
    
    if len(name) > 50:
        return False, "Name must be less than 50 characters"
    
    # Check for valid characters (letters, spaces, hyphens, apostrophes)
    if not re.match(r"^[a-zA-Z\s\-'\.]+$", name):
        return False, "Name contains invalid characters"
    
    return True, None

def validate_passport(passport: str) -> tuple[bool, Optional[str]]:
    """Validate passport number"""
    if not passport or not passport.strip():
        return False, "Passport number cannot be empty"
    
    if len(passport) < 6 or len(passport) > 20:
        return False, "Passport number must be between 6 and 20 characters"
    
    # Check for valid characters (alphanumeric)
    if not re.match(r"^[a-zA-Z0-9]+$", passport):
        return False, "Passport number can only contain letters and numbers"
    
    return True, None

def validate_flight_id(flight_id: str) -> tuple[bool, Optional[str]]:
    """Validate flight ID format"""
    if not flight_id or not flight_id.strip():
        return False, "Flight ID cannot be empty"
    
    if len(flight_id) > 50:
        return False, "Flight ID must be less than 50 characters"
    
    return True, None

def validate_price(price: float) -> tuple[bool, Optional[str]]:
    """Validate price"""
    if price < 0:
        return False, "Price cannot be negative"
    
    if price > 100000:
        return False, "Price is too high"
    
    return True, None

def sanitize_input(text: str) -> str:
    """Sanitize user input to prevent XSS attacks"""
    if not text:
        return ""
    
    # Remove or escape potentially dangerous characters
    # This is a basic implementation - in production, use a proper library
    sanitized = text.replace("<", "&lt;").replace(">", "&gt;")
    sanitized = sanitized.replace("&", "&amp;").replace('"', "&quot;")
    sanitized = sanitized.replace("'", "&#x27;")
    
    # Remove any null bytes
    sanitized = sanitized.replace("\x00", "")
    
    return sanitized.strip()

def validate_booking_request(
    flight_id: str,
    first_name: str,
    last_name: str,
    email: str,
    passport: str,
    total_price: float
) -> None:
    """Validate all booking request fields"""
    # Validate flight ID
    is_valid, error = validate_flight_id(flight_id)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid flight ID", "INVALID_FLIGHT_ID")
    
    # Validate first name
    is_valid, error = validate_name(first_name)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid first name", "INVALID_FIRST_NAME")
    
    # Validate last name
    is_valid, error = validate_name(last_name)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid last name", "INVALID_LAST_NAME")
    
    # Validate email
    if not validate_email(email):
        raise SkyScanException(400, "Invalid email format", "INVALID_EMAIL")
    
    # Validate passport
    is_valid, error = validate_passport(passport)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid passport number", "INVALID_PASSPORT")
    
    # Validate price
    is_valid, error = validate_price(total_price)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid price", "INVALID_PRICE")

def validate_user_registration(
    first_name: str,
    last_name: str,
    email: str,
    password: str
) -> None:
    """Validate user registration fields"""
    # Validate first name
    is_valid, error = validate_name(first_name)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid first name", "INVALID_FIRST_NAME")
    
    # Validate last name
    is_valid, error = validate_name(last_name)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid last name", "INVALID_LAST_NAME")
    
    # Validate email
    if not validate_email(email):
        raise SkyScanException(400, "Invalid email format", "INVALID_EMAIL")
    
    # Validate password
    is_valid, error = validate_password(password)
    if not is_valid:
        raise SkyScanException(400, error or "Invalid password", "INVALID_PASSWORD")