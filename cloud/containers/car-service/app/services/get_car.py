from __future__ import annotations

from typing import Dict, Any
import app.repositories as repo
import logging

logger = logging.getLogger(__name__)


def get_car(data: Dict[str, Any]) -> Dict[str, Any]:
    """Get a car by ID.
    
    Args:
        data: Dictionary containing carId
        
    Returns:
        Dictionary with car data
        
    Raises:
        ValueError: If carId is missing or invalid
        LookupError: If car not found
    """
    
    car_id = data.get("carId")
    if not car_id:
        raise ValueError("carId is required")
    
    car = repo.get_car(car_id)
    if not car:
        raise LookupError(f"Car with ID {car_id} not found")
    
    return car.model_dump(mode='json')
