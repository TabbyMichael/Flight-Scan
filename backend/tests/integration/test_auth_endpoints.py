import pytest
from unittest.mock import patch, MagicMock
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)

class TestAuthEndpoints:
    """Integration tests for authentication endpoints"""
    
    def test_register_user_success(self):
        """Test successful user registration"""
        # Test data
        user_data = {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john@example.com",
            "password": "SecurePass123!"
        }
        
        # Mock the database manager
        with patch('app.main.database_manager') as mock_db_manager:
            # Mock user creation to return True (success)
            mock_db_manager.create_user.return_value = True
            
            # Mock get_user_by_email to return None (user doesn't exist)
            mock_db_manager.get_user_by_email.return_value = None
            
            # Mock the user response
            mock_user_response = {
                "id": "user_123",
                "first_name": "John",
                "last_name": "Doe",
                "email": "john@example.com",
                "created_at": "2023-01-01T00:00:00"
            }
            
            # Send POST request
            response = client.post("/auth/register", json=user_data)
            
            # Verify response
            assert response.status_code == 200
            data = response.json()
            assert data["first_name"] == "John"
            assert data["email"] == "john@example.com"
            
            # Verify database methods were called
            mock_db_manager.get_user_by_email.assert_called_once_with("john@example.com")
            mock_db_manager.create_user.assert_called_once()

    def test_register_user_duplicate_email(self):
        """Test user registration with duplicate email"""
        # Test data
        user_data = {
            "first_name": "John",
            "last_name": "Doe",
            "email": "john@example.com",
            "password": "SecurePass123!"
        }
        
        # Mock the database manager
        with patch('app.main.database_manager') as mock_db_manager:
            # Mock get_user_by_email to return existing user
            mock_db_manager.get_user_by_email.return_value = {
                "id": "existing_user",
                "first_name": "John",
                "last_name": "Doe",
                "email": "john@example.com",
                "password_hash": "hashed_password",
                "created_at": "2023-01-01T00:00:00"
            }
            
            # Send POST request
            response = client.post("/auth/register", json=user_data)
            
            # Verify response
            assert response.status_code == 400
            data = response.json()
            assert "already exists" in data["detail"]
            
            # Verify database method was called
            mock_db_manager.get_user_by_email.assert_called_once_with("john@example.com")

    def test_login_user_success(self):
        """Test successful user login"""
        # Test data
        login_data = {
            "email": "john@example.com",
            "password": "SecurePass123!"
        }
        
        # Mock the database manager
        with patch('app.main.database_manager') as mock_db_manager:
            # Mock get_user_by_email to return existing user
            mock_db_manager.get_user_by_email.return_value = {
                "id": "user_123",
                "first_name": "John",
                "last_name": "Doe",
                "email": "john@example.com",
                "password_hash": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.PZvO.S",  # bcrypt hash of "SecurePass123!"
                "created_at": "2023-01-01T00:00:00"
            }
            
            # Mock verify_password to return True
            with patch('app.main.verify_password', return_value=True):
                # Mock create_access_token to return a test token
                with patch('app.main.create_access_token', return_value="test_token"):
                    # Send POST request
                    response = client.post("/auth/login", json=login_data)
                    
                    # Verify response
                    assert response.status_code == 200
                    data = response.json()
                    assert "access_token" in data
                    assert data["access_token"] == "test_token"
                    assert data["token_type"] == "bearer"
                    
                    # Verify database method was called
                    mock_db_manager.get_user_by_email.assert_called_once_with("john@example.com")

    def test_login_user_invalid_credentials(self):
        """Test user login with invalid credentials"""
        # Test data
        login_data = {
            "email": "john@example.com",
            "password": "WrongPassword"
        }
        
        # Mock the database manager
        with patch('app.main.database_manager') as mock_db_manager:
            # Mock get_user_by_email to return existing user
            mock_db_manager.get_user_by_email.return_value = {
                "id": "user_123",
                "first_name": "John",
                "last_name": "Doe",
                "email": "john@example.com",
                "password_hash": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.PZvO.S",  # bcrypt hash of "SecurePass123!"
                "created_at": "2023-01-01T00:00:00"
            }
            
            # Mock verify_password to return False
            with patch('app.main.verify_password', return_value=False):
                # Send POST request
                response = client.post("/auth/login", json=login_data)
                
                # Verify response
                assert response.status_code == 401
                data = response.json()
                assert "Invalid credentials" in data["detail"]
                
                # Verify database method was called
                mock_db_manager.get_user_by_email.assert_called_once_with("john@example.com")

if __name__ == "__main__":
    pytest.main([__file__])