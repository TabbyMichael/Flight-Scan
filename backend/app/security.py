import jwt
import os
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from .exception_handlers import SkyScanException

# Secret key for JWT - in production, use environment variables
SECRET_KEY = os.environ.get("JWT_SECRET_KEY", "skyscan_secret_key_2025")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT access token"""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Dict[str, Any]:
    """Decode a JWT access token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise SkyScanException(401, "Token has expired", "TOKEN_EXPIRED")
    except jwt.InvalidTokenError:
        raise SkyScanException(401, "Invalid token", "INVALID_TOKEN")

def hash_password(password: str) -> str:
    """Hash a password with a random salt"""
    import secrets
    import hashlib
    
    salt = secrets.token_hex(16)
    pwdhash = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt.encode('utf-8'), 100000)
    return salt + pwdhash.hex()

def verify_password(stored_password: str, provided_password: str) -> bool:
    """Verify a stored password against one provided by user"""
    salt = stored_password[:32]
    stored_pwdhash = stored_password[32:]
    import hashlib
    pwdhash = hashlib.pbkdf2_hmac('sha256', provided_password.encode('utf-8'), salt.encode('utf-8'), 100000)
    return pwdhash.hex() == stored_pwdhash

def generate_secure_password() -> str:
    """Generate a secure random password"""
    import secrets
    import string
    
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(12))

def validate_password_strength(password: str) -> tuple[bool, Optional[str]]:
    """Validate password strength"""
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    
    if len(password) > 128:
        return False, "Password must be less than 128 characters long"
    
    # Check for at least one uppercase letter
    if not any(c.isupper() for c in password):
        return False, "Password must contain at least one uppercase letter"
    
    # Check for at least one lowercase letter
    if not any(c.islower() for c in password):
        return False, "Password must contain at least one lowercase letter"
    
    # Check for at least one digit
    if not any(c.isdigit() for c in password):
        return False, "Password must contain at least one digit"
    
    # Check for at least one special character
    if not any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
        return False, "Password must contain at least one special character"
    
    return True, None

def rate_limit_check(ip_address: str, max_attempts: int = 5, window_minutes: int = 15) -> bool:
    """Check if an IP address has exceeded rate limits"""
    # This is a simplified implementation
    # In production, you would use Redis or similar for persistent storage
    import time
    
    # For demo purposes, we'll just return True (no rate limiting)
    # A real implementation would track attempts per IP
    return True

def is_secure_password(password: str) -> bool:
    """Check if a password meets security requirements"""
    is_valid, _ = validate_password_strength(password)
    return is_valid

def sanitize_username(username: str) -> str:
    """Sanitize username to prevent injection attacks"""
    if not username:
        return ""
    
    # Remove potentially dangerous characters
    sanitized = ''.join(c for c in username if c.isalnum() or c in ['_', '-', '.'])
    
    # Limit length
    return sanitized[:50]

def validate_session_token(token: str) -> bool:
    """Validate a session token"""
    try:
        decode_access_token(token)
        return True
    except:
        return False