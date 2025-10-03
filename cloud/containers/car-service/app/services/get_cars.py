import app.repositories as repo
from typing import Dict, Any, List
import logging

logger = logging.getLogger(__name__)


def get_cars(payload: dict) -> List[Dict[str, Any]]:
    """
    Get list of all cars.
    
    Args:
        payload: Dictionary (currently unused, for future filters)
    
    Returns:
        List of car dictionaries
    """

    # Get all cars from repository
    cars = repo.get_cars()
    
    # Convert Pydantic models to dicts with JSON serialization
    cars_data = [car.model_dump(mode='json') for car in cars]
    
    return cars_data
