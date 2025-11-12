import pytest
import os
from unittest.mock import patch, MagicMock
from app.postgres_db import PostgresDatabaseManager, User, Booking, Flight, ExtraService

class TestPostgresDatabaseManager:
    """Test cases for PostgresDatabaseManager class"""
    
    @patch('app.postgres_db.create_engine')
    @patch('app.postgres_db.sessionmaker')
    def test_init_db(self, mock_sessionmaker, mock_create_engine):
        """Test database initialization"""
        # Mock the engine and session
        mock_engine = MagicMock()
        mock_create_engine.return_value = mock_engine
        mock_sessionmaker.return_value = MagicMock()
        
        # Create database manager instance
        db_manager = PostgresDatabaseManager("postgresql://test:test@localhost/test")
        
        # Verify engine was created with correct URL
        mock_create_engine.assert_called_once_with("postgresql://test:test@localhost/test", echo=False)
        
        # Verify sessionmaker was called
        mock_sessionmaker.assert_called_once_with(autocommit=False, autoflush=False, bind=mock_engine)
        
        # Verify _init_db was called
        assert hasattr(db_manager, 'engine')
        assert hasattr(db_manager, 'SessionLocal')

    @patch('app.postgres_db.Base')
    def test_init_db_creates_tables(self, mock_base):
        """Test that _init_db creates tables"""
        with patch.object(PostgresDatabaseManager, '__init__', lambda x, database_url=None: None):
            db_manager = PostgresDatabaseManager.__new__(PostgresDatabaseManager)
            db_manager.engine = MagicMock()
            
            # Call _init_db
            db_manager._init_db = PostgresDatabaseManager._init_db.__get__(db_manager, PostgresDatabaseManager)
            db_manager._init_db()
            
            # Verify create_all was called
            mock_base.metadata.create_all.assert_called_once_with(bind=db_manager.engine)

if __name__ == "__main__":
    pytest.main([__file__])