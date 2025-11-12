#!/usr/bin/env python3
"""
Script to initialize the PostgreSQL database for SkyScan Flight Viewer.
This script creates the database and user if they don't exist.
"""

import psycopg2
import sys
import os
from psycopg2 import sql

# Default database configuration
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_PORT = os.environ.get('DB_PORT', '5432')
DB_NAME = os.environ.get('DB_NAME', 'skyscan_db')
DB_USER = os.environ.get('DB_USER', 'skyscan_user')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'skyscan_pass')
DB_ADMIN_USER = os.environ.get('DB_ADMIN_USER', 'postgres')
DB_ADMIN_PASSWORD = os.environ.get('DB_ADMIN_PASSWORD', '')

def connect_as_admin():
    """Connect to PostgreSQL as admin user"""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database='postgres',  # Connect to default database
            user=DB_ADMIN_USER,
            password=DB_ADMIN_PASSWORD
        )
        conn.autocommit = True
        return conn
    except Exception as e:
        print(f"Failed to connect as admin: {e}")
        return None

def create_database_and_user():
    """Create database and user if they don't exist"""
    conn = connect_as_admin()
    if not conn:
        print("Cannot connect as admin. Please ensure PostgreSQL is running and admin credentials are correct.")
        return False
    
    try:
        cursor = conn.cursor()
        
        # Check if database exists
        cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = %s", (DB_NAME,))
        exists = cursor.fetchone()
        
        if not exists:
            print(f"Creating database '{DB_NAME}'...")
            cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(DB_NAME)))
            print(f"Database '{DB_NAME}' created successfully.")
        else:
            print(f"Database '{DB_NAME}' already exists.")
        
        # Check if user exists
        cursor.execute("SELECT 1 FROM pg_catalog.pg_user WHERE usename = %s", (DB_USER,))
        exists = cursor.fetchone()
        
        if not exists:
            print(f"Creating user '{DB_USER}'...")
            cursor.execute(
                sql.SQL("CREATE USER {} WITH PASSWORD %s").format(sql.Identifier(DB_USER)),
                (DB_PASSWORD,)
            )
            print(f"User '{DB_USER}' created successfully.")
        else:
            print(f"User '{DB_USER}' already exists.")
        
        # Grant privileges
        print(f"Granting privileges on database '{DB_NAME}' to user '{DB_USER}'...")
        cursor.execute(
            sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {}").format(
                sql.Identifier(DB_NAME),
                sql.Identifier(DB_USER)
            )
        )
        print("Privileges granted successfully.")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"Error creating database and user: {e}")
        return False

def test_connection():
    """Test connection to the application database"""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        if version:
            print(f"Successfully connected to database. PostgreSQL version: {version[0]}")
        else:
            print("Successfully connected to database, but could not retrieve version.")
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"Failed to connect to database: {e}")
        return False

def main():
    print("Initializing PostgreSQL database for SkyScan Flight Viewer...")
    print(f"Host: {DB_HOST}:{DB_PORT}")
    print(f"Database: {DB_NAME}")
    print(f"User: {DB_USER}")
    print()
    
    # Create database and user
    if not create_database_and_user():
        print("Failed to create database and user.")
        sys.exit(1)
    
    # Test connection
    print("\nTesting database connection...")
    if not test_connection():
        print("Failed to connect to the database.")
        sys.exit(1)
    
    print("\nDatabase initialization completed successfully!")
    print("\nTo use the PostgreSQL database, make sure to set the DATABASE_URL environment variable:")
    print(f"  export DATABASE_URL=postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
    print("\nOr add it to your .env file:")
    print(f"  DATABASE_URL=postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

if __name__ == "__main__":
    main()