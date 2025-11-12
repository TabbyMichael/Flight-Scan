# PostgreSQL Database Setup for SkyScan Flight Viewer

This guide explains how to set up and use PostgreSQL as the database for the SkyScan Flight Viewer application.

## Prerequisites

1. PostgreSQL installed on your system
2. Python 3.8 or higher
3. pip package manager

## Installation

1. Install the required Python packages:
   ```bash
   pip install psycopg2-binary SQLAlchemy
   ```

   Or if you're using the system Python on Linux:
   ```bash
   pip install --break-system-packages psycopg2-binary SQLAlchemy
   ```

2. Start your PostgreSQL server (if not already running):
   ```bash
   sudo systemctl start postgresql
   ```

## Database Initialization

1. Run the initialization script:
   ```bash
   cd backend
   python init_postgres_db.py
   ```

2. The script will:
   - Create a database named `skyscan_db`
   - Create a user named `skyscan_user` with password `skyscan_pass`
   - Grant all privileges on the database to the user

## Environment Configuration

The application will automatically use the PostgreSQL database. By default, it connects using:
```
postgresql://skyscan_user:skyscan_pass@localhost:5432/skyscan_db
```

To customize the connection, set the `DATABASE_URL` environment variable:
```bash
export DATABASE_URL=postgresql://username:password@host:port/database_name
```

Or create a `.env` file in the backend directory with:
```
DATABASE_URL=postgresql://username:password@host:port/database_name
```

## Tables Created

The application will automatically create the following tables:

1. **users** - Stores user account information
2. **bookings** - Stores flight booking information
3. **flights** - Caches flight data (optional)

## Migration from SQLite

If you were previously using SQLite, the application will now use PostgreSQL instead. No data migration is provided in this version, so you'll start with a fresh database.

## Troubleshooting

### Permission denied errors
If you get permission errors, you may need to run the initialization script with appropriate PostgreSQL admin credentials:
```bash
DB_ADMIN_USER=postgres DB_ADMIN_PASSWORD=your_admin_password python init_postgres_db.py
```

### Connection refused
Make sure PostgreSQL is running:
```bash
sudo systemctl status postgresql
```

### Authentication failed
Verify the database credentials in your environment variables or .env file.