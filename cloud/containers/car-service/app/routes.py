from typing import List
from fastapi import APIRouter, HTTPException, status, Request
from anyio import to_thread

from app.schemas import Car
from app.services.get_cars import get_cars as get_cars_service
from app.services.get_car import get_car as get_car_service

router = APIRouter(prefix="/v1/cars", tags=["Cars"])

# ------------------------------------------------------------------
# Get all cars
# ------------------------------------------------------------------
@router.get("", response_model=List[Car], status_code=status.HTTP_200_OK)
async def get_cars(request: Request):  
    """
    Get list of all cars.
    """
    payload = {}
    result = await to_thread.run_sync(get_cars_service, payload)
    return result

# ------------------------------------------------------------------
# Get single car by ID
# ------------------------------------------------------------------
@router.get("/{carId}", response_model=Car, status_code=status.HTTP_200_OK)
async def get_car(request: Request, carId: str):
    """
    Get car information by ID.
    """
    payload = {
        "carId": carId,
    }
    result = await to_thread.run_sync(get_car_service, payload)
    return result
