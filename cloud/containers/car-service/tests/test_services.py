"""
Tests for service layer functions.
"""
import pytest
from unittest.mock import patch, MagicMock
from uuid import uuid4

from app.services.get_car import get_car
from app.services.get_cars import get_cars
from app.schemas import Car


class TestGetCarsService:
    """Tests for get_cars service function."""
    
    def test_get_cars_returns_list(self, mock_firebase, sample_car_data):
        """Test that get_cars returns a list of car dictionaries."""
        # Mock the repository
        mock_car = Car(**sample_car_data)
        
        with patch('app.services.get_cars.repo') as mock_repo:
            mock_repo.get_cars.return_value = [mock_car]
            
            result = get_cars({})
            
            assert isinstance(result, list)
            assert len(result) == 1
            assert result[0]["make"] == sample_car_data["make"]
    
    def test_get_cars_empty_list(self, mock_firebase):
        """Test get_cars with no cars in database."""
        with patch('app.services.get_cars.repo') as mock_repo:
            mock_repo.get_cars.return_value = []
            
            result = get_cars({})
            
            assert result == []
    
    def test_get_cars_multiple_cars(self, mock_firebase, multiple_cars_data):
        """Test get_cars with multiple cars."""
        mock_cars = [Car(**data) for data in multiple_cars_data]
        
        with patch('app.services.get_cars.repo') as mock_repo:
            mock_repo.get_cars.return_value = mock_cars
            
            result = get_cars({})
            
            assert len(result) == len(multiple_cars_data)
    
    def test_get_cars_converts_to_json(self, mock_firebase, sample_car_data):
        """Test that get_cars converts Pydantic models to JSON-serializable dicts."""
        mock_car = Car(**sample_car_data)
        
        with patch('app.services.get_cars.repo') as mock_repo:
            mock_repo.get_cars.return_value = [mock_car]
            
            result = get_cars({})
            
            # ID should be a string (JSON serialized)
            assert isinstance(result[0]["id"], str)


class TestGetCarService:
    """Tests for get_car service function."""
    
    def test_get_car_success(self, mock_firebase, sample_car_data):
        """Test successful car retrieval by ID."""
        car_id = sample_car_data["id"]
        mock_car = Car(**sample_car_data)
        
        with patch('app.services.get_car.repo') as mock_repo:
            mock_repo.get_car.return_value = mock_car
            
            result = get_car({"carId": car_id})
            
            assert result["id"] == car_id
            assert result["make"] == sample_car_data["make"]
            mock_repo.get_car.assert_called_once_with(car_id)
    
    def test_get_car_not_found(self, mock_firebase):
        """Test get_car when car doesn't exist."""
        with patch('app.services.get_car.repo') as mock_repo:
            mock_repo.get_car.return_value = None
            
            with pytest.raises(LookupError) as exc_info:
                get_car({"carId": "non-existent-id"})
            
            assert "not found" in str(exc_info.value)
    
    def test_get_car_missing_car_id(self, mock_firebase):
        """Test get_car with missing carId."""
        with pytest.raises(ValueError) as exc_info:
            get_car({})
        
        assert "carId is required" in str(exc_info.value)
    
    def test_get_car_empty_car_id(self, mock_firebase):
        """Test get_car with empty carId."""
        with pytest.raises(ValueError) as exc_info:
            get_car({"carId": ""})
        
        assert "carId is required" in str(exc_info.value)
    
    def test_get_car_none_car_id(self, mock_firebase):
        """Test get_car with None carId."""
        with pytest.raises(ValueError) as exc_info:
            get_car({"carId": None})
        
        assert "carId is required" in str(exc_info.value)
    
    def test_get_car_converts_to_json(self, mock_firebase, sample_car_data):
        """Test that get_car converts Pydantic model to JSON-serializable dict."""
        mock_car = Car(**sample_car_data)
        
        with patch('app.services.get_car.repo') as mock_repo:
            mock_repo.get_car.return_value = mock_car
            
            result = get_car({"carId": sample_car_data["id"]})
            
            # Verify result is JSON serializable
            import json
            json_str = json.dumps(result)
            assert json_str is not None

