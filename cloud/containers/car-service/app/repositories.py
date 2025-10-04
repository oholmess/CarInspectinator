from __future__ import annotations

from typing import Optional, Dict, Any, List
from uuid import UUID

from app.schemas import Car
from app.firebase import get_firestore_client
from app.storage import get_model_url_for_volume_id

import logging
logger = logging.getLogger(__name__)

# Firestore collection name
CARS_COLLECTION = "cars"


def get_cars() -> List[Car]:
    """
    Get all cars from Firestore.
    
    Returns:
        List of Car objects with signed model URLs
    """
    try:
        db = get_firestore_client()
        cars_ref = db.collection(CARS_COLLECTION)
        docs = cars_ref.stream()
        
        cars = []
        for doc in docs:
            try:
                car_data = doc.to_dict()
                # Firestore ID is the string UUID
                car_data['id'] = doc.id
                car = Car(**car_data)
                
                # Generate signed URL for 3D model if volumeId exists
                if car.volumeId and not car.modelUrl:
                    car.modelUrl = get_model_url_for_volume_id(car.volumeId)
                
                cars.append(car)
            except Exception as e:
                logger.error(f"Error parsing car document {doc.id}: {e}")
                continue
        
        logger.info(f"Retrieved {len(cars)} cars from Firestore")
        return cars
        
    except Exception as e:
        logger.error(f"Error retrieving cars from Firestore: {e}")
        return []


def get_car(car_id: str) -> Optional[Car]:
    """
    Get a single car by ID from Firestore.
    
    Args:
        car_id: UUID string of the car
        
    Returns:
        Car object with signed model URL if found, None otherwise
    """
    try:
        # Validate UUID format
        try:
            UUID(car_id)
        except ValueError:
            logger.warning(f"Invalid UUID format: {car_id}")
            return None
        
        db = get_firestore_client()
        doc_ref = db.collection(CARS_COLLECTION).document(car_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            logger.info(f"Car not found: {car_id}")
            return None
        
        car_data = doc.to_dict()
        car_data['id'] = doc.id
        car = Car(**car_data)
        
        # Generate signed URL for 3D model if volumeId exists
        if car.volumeId and not car.modelUrl:
            car.modelUrl = get_model_url_for_volume_id(car.volumeId)
        
        logger.info(f"Retrieved car: {car_id}")
        return car
        
    except Exception as e:
        logger.error(f"Error retrieving car {car_id} from Firestore: {e}")
        return None


def create_car(car: Car) -> bool:
    """
    Create a new car document in Firestore.
    
    Args:
        car: Car object to create
        
    Returns:
        True if successful, False otherwise
    """
    try:
        db = get_firestore_client()
        car_id = str(car.id)
        
        # Convert to dict and remove id (it's the document ID)
        car_data = car.model_dump(mode='json', exclude={'id'})
        
        db.collection(CARS_COLLECTION).document(car_id).set(car_data)
        logger.info(f"Created car: {car_id}")
        return True
        
    except Exception as e:
        logger.error(f"Error creating car in Firestore: {e}")
        return False


def update_car(car_id: str, car: Car) -> bool:
    """
    Update an existing car document in Firestore.
    
    Args:
        car_id: UUID string of the car
        car: Car object with updated data
        
    Returns:
        True if successful, False otherwise
    """
    try:
        db = get_firestore_client()
        
        # Convert to dict and remove id
        car_data = car.model_dump(mode='json', exclude={'id'})
        
        db.collection(CARS_COLLECTION).document(car_id).update(car_data)
        logger.info(f"Updated car: {car_id}")
        return True
        
    except Exception as e:
        logger.error(f"Error updating car {car_id} in Firestore: {e}")
        return False


def delete_car(car_id: str) -> bool:
    """
    Delete a car document from Firestore.
    
    Args:
        car_id: UUID string of the car
        
    Returns:
        True if successful, False otherwise
    """
    try:
        db = get_firestore_client()
        db.collection(CARS_COLLECTION).document(car_id).delete()
        logger.info(f"Deleted car: {car_id}")
        return True
        
    except Exception as e:
        logger.error(f"Error deleting car {car_id} from Firestore: {e}")
        return False