from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging

from app.routes import router
from app.firebase import initialize_firebase
from common.errors import APIError

logger = logging.getLogger(__name__)

app = FastAPI(
    title="Car Service",
    description="HTTP service for managing cars",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup_event():
    """Initialize Firebase on application startup."""
    try:
        initialize_firebase()
        logger.info("Firebase initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        # You may want to raise this to prevent the app from starting
        # raise


# Health endpoint for readiness probes
@app.get("/health", tags=["Health"], summary="Health check")
async def health_check():
    return {"status": "ok", "service": "car-service"}

# Include the inventory item routes
app.include_router(router)

# ------------------------------------------------------------------
# Global exception handler for our custom APIError hierarchy
# ------------------------------------------------------------------
@app.exception_handler(APIError)
async def api_error_handler(request: Request, exc: APIError):
    """Return JSON response based on APIError.* sub-classes."""
    return JSONResponse(status_code=exc.status_code, content=exc.to_dict())
