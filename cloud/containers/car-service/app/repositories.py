from __future__ import annotations

from typing import Optional, Dict, Any, List
from uuid import UUID

from app.schemas import DB, Car

import logging
logger = logging.getLogger(__name__)


def get_cars() -> List[Car]:
    """
    Get all cars from the in-memory database.
    
    Returns:
        List of Car objects
    """
    return list(DB.values())


def get_car(car_id: str) -> Optional[Car]:
    """
    Get a single car by ID.
    
    Args:
        car_id: UUID string of the car
        
    Returns:
        Car object if found, None otherwise
    """
    try:
        uuid_id = UUID(car_id)
        return DB.get(uuid_id)
    except (ValueError, AttributeError):
        return None