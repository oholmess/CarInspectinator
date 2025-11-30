"""
Pytest configuration and fixtures for car-service tests.
"""
import pytest
from unittest.mock import MagicMock, patch
from uuid import uuid4
from typing import List

from fastapi.testclient import TestClient


# ============================================================
# Mock Firebase/Firestore before importing app modules
# ============================================================

@pytest.fixture(autouse=True)
def mock_firebase():
    """Mock Firebase initialization for all tests."""
    with patch('app.firebase.firebase_admin') as mock_admin, \
         patch('app.firebase.firestore') as mock_firestore:
        # Setup mock Firestore client
        mock_db = MagicMock()
        mock_firestore.client.return_value = mock_db
        
        yield {
            'admin': mock_admin,
            'firestore': mock_firestore,
            'db': mock_db
        }


@pytest.fixture
def mock_storage():
    """Mock Google Cloud Storage for tests."""
    with patch('app.storage.storage.Client') as mock_client:
        mock_bucket = MagicMock()
        mock_blob = MagicMock()
        mock_blob.exists.return_value = True
        mock_blob.generate_signed_url.return_value = "https://storage.googleapis.com/signed-url"
        mock_bucket.blob.return_value = mock_blob
        mock_client.return_value.bucket.return_value = mock_bucket
        
        yield {
            'client': mock_client,
            'bucket': mock_bucket,
            'blob': mock_blob
        }


@pytest.fixture
def test_client(mock_firebase):
    """Create a test client for the FastAPI app."""
    from app.main import app
    
    with TestClient(app) as client:
        yield client


@pytest.fixture
def sample_car_data():
    """Sample car data for testing."""
    return {
        "id": str(uuid4()),
        "make": "BMW",
        "model": "M3",
        "blurb": "A sporty sedan with impressive performance",
        "iconAssetName": "bmw_m3",
        "year": 2024,
        "bodyStyle": "Sedan",
        "exteriorColor": "Alpine White",
        "interiorColor": "Black",
        "volumeId": "bmw_m3_2024",
        "engine": {
            "displacement": {"value": 3.0, "unit": "liters"},
            "cylinders": 6,
            "configuration": "I6",
            "fuel": "gasoline",
            "induction": "turbocharged",
            "code": "S58"
        },
        "performance": {
            "horsepower": {"value": 473, "unit": "horsepower"},
            "torque": {"value": 406, "unit": "poundForceFeet"},
            "zeroToSixty": {"value": 4.1, "unit": "seconds"},
            "topSpeed": {"value": 155, "unit": "milesPerHour"}
        },
        "dimensions": {
            "wheelbase": {"value": 112.8, "unit": "inches"},
            "length": {"value": 189.1, "unit": "inches"},
            "width": {"value": 74.3, "unit": "inches"},
            "height": {"value": 56.9, "unit": "inches"},
            "curbWeight": {"value": 3830, "unit": "pounds"}
        },
        "drivetrain": {
            "layout": "rwd",
            "transmission": "manual",
            "gears": 6
        },
        "otherSpecs": {}
    }


@pytest.fixture
def sample_car_minimal():
    """Minimal car data with only required fields."""
    return {
        "id": str(uuid4()),
        "make": "Toyota",
        "model": "Camry"
    }


@pytest.fixture
def multiple_cars_data(sample_car_data):
    """Multiple car data for testing list endpoints."""
    cars = []
    makes_models = [
        ("BMW", "M3"),
        ("Audi", "RS7"),
        ("Mercedes", "G63"),
        ("Toyota", "Supra")
    ]
    
    for make, model in makes_models:
        car = sample_car_data.copy()
        car["id"] = str(uuid4())
        car["make"] = make
        car["model"] = model
        car["iconAssetName"] = f"{make.lower()}_{model.lower()}"
        cars.append(car)
    
    return cars

