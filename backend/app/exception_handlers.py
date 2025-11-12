from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from typing import Optional
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SkyScanException(Exception):
    """Custom exception class for SkyScan application"""
    def __init__(self, status_code: int, detail: str, error_code: Optional[str] = None):
        self.status_code = status_code
        self.detail = detail
        self.error_code = error_code

def add_exception_handlers(app: FastAPI):
    """Add custom exception handlers to the FastAPI app"""
    
    @app.exception_handler(SkyScanException)
    async def skyscan_exception_handler(request: Request, exc: SkyScanException):
        logger.error(f"SkyScanException: {exc.detail}")
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": {
                    "type": "application_error",
                    "message": exc.detail,
                    "code": exc.error_code
                }
            }
        )
    
    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        logger.error(f"HTTPException: {exc.detail}")
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": {
                    "type": "http_error",
                    "message": exc.detail,
                    "code": exc.status_code
                }
            }
        )
    
    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        logger.error(f"Unhandled exception: {str(exc)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={
                "error": {
                    "type": "internal_server_error",
                    "message": "An unexpected error occurred",
                    "code": "INTERNAL_ERROR"
                }
            }
        )

def handle_database_error():
    """Helper function to handle database errors"""
    raise SkyScanException(
        status_code=500,
        detail="Database operation failed",
        error_code="DATABASE_ERROR"
    )

def handle_validation_error(field: str, message: str):
    """Helper function to handle validation errors"""
    raise SkyScanException(
        status_code=400,
        detail=f"Validation error in field '{field}': {message}",
        error_code="VALIDATION_ERROR"
    )

def handle_authentication_error():
    """Helper function to handle authentication errors"""
    raise SkyScanException(
        status_code=401,
        detail="Authentication required",
        error_code="AUTHENTICATION_REQUIRED"
    )

def handle_authorization_error():
    """Helper function to handle authorization errors"""
    raise SkyScanException(
        status_code=403,
        detail="Insufficient permissions",
        error_code="INSUFFICIENT_PERMISSIONS"
    )

def handle_not_found_error(resource: str):
    """Helper function to handle not found errors"""
    raise SkyScanException(
        status_code=404,
        detail=f"{resource} not found",
        error_code="RESOURCE_NOT_FOUND"
    )