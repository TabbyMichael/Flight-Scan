# SkyScan Flight API

This is the backend API for the SkyScan Flight Search and Booking Management Application.

## Setup

1. Create a virtual environment (recommended):

   # On Windows: venv\Scripts\activate

   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt  

      # On Windows: venv\Scripts\activate

   python3.11 -m venv venv
   source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt  # On Mac: venv\Scripts\activate
   ```


## Running the API

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, you can access:

- Interactive API documentation: http://localhost:8000/docs
- Alternative documentation: http://localhost:8000/redoc

## Environment Variables

Create a `.env` file in the root directory to set environment variables if needed.

## API Endpoints

- `GET /` - Health check
- `GET /flights` - Get all flights
- `POST /flights/search` - Search flights with filters
- `GET /airlines` - Get list of airlines
- `GET /services` - Get extra services
- `GET /trip/{pnr}` - Get trip details by PNR

## Development

For development, you can use the `--reload` flag to enable auto-reload:

```bash
uvicorn app.main:app --reload
```
