"""
Tests for repository layer (Firestore operations).
"""
import pytest
from unittest.mock import patch, MagicMock, PropertyMock
from uuid import uuid4

from app.schemas import Car


class TestGetCarsRepository:
    """Tests for get_cars repository function."""
    
    def test_get_cars_returns_list(self, sample_car_data):
        """Test that get_cars returns a list of Car objects."""
        with patch('app.repositories.get_firestore_client') as mock_get_client, \
             patch('app.repositories.get_model_url_for_volume_id') as mock_get_url:
            
            # Setup mock Firestore
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            mock_get_url.return_value = "https://example.com/model.usdz"
            
            # Create mock document
            mock_doc = MagicMock()
            mock_doc.id = sample_car_data["id"]
            mock_doc.to_dict.return_value = {k: v for k, v in sample_car_data.items() if k != "id"}
            
            mock_collection = MagicMock()
            mock_collection.stream.return_value = [mock_doc]
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import get_cars
            result = get_cars()
            
            assert isinstance(result, list)
            assert len(result) == 1
            assert isinstance(result[0], Car)
    
    def test_get_cars_empty_collection(self):
        """Test get_cars with empty collection."""
        with patch('app.repositories.get_firestore_client') as mock_get_client:
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            
            mock_collection = MagicMock()
            mock_collection.stream.return_value = []
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import get_cars
            result = get_cars()
            
            assert result == []
    
    def test_get_cars_handles_error(self):
        """Test get_cars handles Firestore errors gracefully."""
        with patch('app.repositories.get_firestore_client') as mock_get_client:
            mock_get_client.side_effect = Exception("Firestore error")
            
            from app.repositories import get_cars
            result = get_cars()
            
            assert result == []


class TestGetCarRepository:
    """Tests for get_car repository function."""
    
    def test_get_car_success(self, sample_car_data):
        """Test successful car retrieval."""
        car_id = sample_car_data["id"]
        
        with patch('app.repositories.get_firestore_client') as mock_get_client, \
             patch('app.repositories.get_model_url_for_volume_id') as mock_get_url:
            
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            mock_get_url.return_value = "https://example.com/model.usdz"
            
            # Create mock document
            mock_doc = MagicMock()
            mock_doc.exists = True
            mock_doc.id = car_id
            mock_doc.to_dict.return_value = {k: v for k, v in sample_car_data.items() if k != "id"}
            
            mock_doc_ref = MagicMock()
            mock_doc_ref.get.return_value = mock_doc
            
            mock_collection = MagicMock()
            mock_collection.document.return_value = mock_doc_ref
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import get_car
            result = get_car(car_id)
            
            assert result is not None
            assert isinstance(result, Car)
            assert str(result.id) == car_id
    
    def test_get_car_not_found(self):
        """Test get_car when document doesn't exist."""
        car_id = str(uuid4())
        
        with patch('app.repositories.get_firestore_client') as mock_get_client:
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            
            mock_doc = MagicMock()
            mock_doc.exists = False
            
            mock_doc_ref = MagicMock()
            mock_doc_ref.get.return_value = mock_doc
            
            mock_collection = MagicMock()
            mock_collection.document.return_value = mock_doc_ref
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import get_car
            result = get_car(car_id)
            
            assert result is None
    
    def test_get_car_invalid_uuid(self):
        """Test get_car with invalid UUID format."""
        with patch('app.repositories.get_firestore_client'):
            from app.repositories import get_car
            result = get_car("invalid-uuid")
            
            assert result is None


class TestCreateCarRepository:
    """Tests for create_car repository function."""
    
    def test_create_car_success(self, sample_car_data):
        """Test successful car creation."""
        with patch('app.repositories.get_firestore_client') as mock_get_client:
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            
            mock_doc_ref = MagicMock()
            mock_collection = MagicMock()
            mock_collection.document.return_value = mock_doc_ref
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import create_car
            car = Car(**sample_car_data)
            result = create_car(car)
            
            assert result is True
            mock_doc_ref.set.assert_called_once()
    
    def test_create_car_error(self, sample_car_data):
        """Test create_car handles errors."""
        with patch('app.repositories.get_firestore_client') as mock_get_client:
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            
            mock_collection = MagicMock()
            mock_collection.document.side_effect = Exception("Create error")
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import create_car
            car = Car(**sample_car_data)
            result = create_car(car)
            
            assert result is False


class TestUpdateCarRepository:
    """Tests for update_car repository function."""
    
    def test_update_car_success(self, sample_car_data):
        """Test successful car update."""
        car_id = sample_car_data["id"]
        
        with patch('app.repositories.get_firestore_client') as mock_get_client:
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            
            mock_doc_ref = MagicMock()
            mock_collection = MagicMock()
            mock_collection.document.return_value = mock_doc_ref
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import update_car
            car = Car(**sample_car_data)
            result = update_car(car_id, car)
            
            assert result is True
            mock_doc_ref.update.assert_called_once()


class TestDeleteCarRepository:
    """Tests for delete_car repository function."""
    
    def test_delete_car_success(self):
        """Test successful car deletion."""
        car_id = str(uuid4())
        
        with patch('app.repositories.get_firestore_client') as mock_get_client:
            mock_db = MagicMock()
            mock_get_client.return_value = mock_db
            
            mock_doc_ref = MagicMock()
            mock_collection = MagicMock()
            mock_collection.document.return_value = mock_doc_ref
            mock_db.collection.return_value = mock_collection
            
            from app.repositories import delete_car
            result = delete_car(car_id)
            
            assert result is True
            mock_doc_ref.delete.assert_called_once()

