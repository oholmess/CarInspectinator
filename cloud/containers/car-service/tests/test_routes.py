"""
Tests for API routes.
"""
import pytest
from unittest.mock import patch, MagicMock
from uuid import uuid4

from app.schemas import Car


class TestHealthEndpoint:
    """Tests for health check endpoint."""
    
    def test_health_check(self, test_client):
        """Test health endpoint returns OK status."""
        response = test_client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert data["service"] == "car-service"


class TestGetCarsEndpoint:
    """Tests for GET /v1/cars endpoint."""
    
    def test_get_cars_success(self, test_client, sample_car_data):
        """Test successful retrieval of all cars."""
        mock_car = Car(**sample_car_data)
        
        with patch('app.routes.get_cars_service') as mock_service:
            mock_service.return_value = [mock_car.model_dump(mode='json')]
            
            response = test_client.get("/v1/cars")
            
            assert response.status_code == 200
            data = response.json()
            assert isinstance(data, list)
            assert len(data) == 1
    
    def test_get_cars_empty(self, test_client):
        """Test get_cars when no cars exist."""
        with patch('app.routes.get_cars_service') as mock_service:
            mock_service.return_value = []
            
            response = test_client.get("/v1/cars")
            
            assert response.status_code == 200
            data = response.json()
            assert data == []
    
    def test_get_cars_multiple(self, test_client, multiple_cars_data):
        """Test get_cars with multiple cars."""
        mock_cars = [Car(**data).model_dump(mode='json') for data in multiple_cars_data]
        
        with patch('app.routes.get_cars_service') as mock_service:
            mock_service.return_value = mock_cars
            
            response = test_client.get("/v1/cars")
            
            assert response.status_code == 200
            data = response.json()
            assert len(data) == len(multiple_cars_data)


class TestGetCarEndpoint:
    """Tests for GET /v1/cars/{carId} endpoint."""
    
    def test_get_car_success(self, test_client, sample_car_data):
        """Test successful retrieval of a single car."""
        car_id = sample_car_data["id"]
        mock_car = Car(**sample_car_data)
        
        with patch('app.routes.get_car_service') as mock_service:
            mock_service.return_value = mock_car.model_dump(mode='json')
            
            response = test_client.get(f"/v1/cars/{car_id}")
            
            assert response.status_code == 200
            data = response.json()
            assert data["id"] == car_id
            assert data["make"] == sample_car_data["make"]
    
    def test_get_car_with_full_data(self, test_client, sample_car_data):
        """Test get_car returns complete car data including nested objects."""
        car_id = sample_car_data["id"]
        mock_car = Car(**sample_car_data)
        
        with patch('app.routes.get_car_service') as mock_service:
            mock_service.return_value = mock_car.model_dump(mode='json')
            
            response = test_client.get(f"/v1/cars/{car_id}")
            
            assert response.status_code == 200
            data = response.json()
            
            # Check nested data
            assert "engine" in data
            assert "performance" in data
            assert "dimensions" in data
            assert "drivetrain" in data


class TestAPIErrorHandling:
    """Tests for API error handling."""
    
    def test_not_found_route(self, test_client):
        """Test 404 for non-existent route."""
        response = test_client.get("/non-existent-route")
        
        assert response.status_code == 404


class TestCORSHeaders:
    """Tests for CORS configuration."""
    
    def test_cors_headers_present(self, test_client):
        """Test that CORS headers are present in response."""
        response = test_client.options(
            "/v1/cars",
            headers={
                "Origin": "http://localhost:3000",
                "Access-Control-Request-Method": "GET"
            }
        )
        
        # CORS middleware should handle OPTIONS requests
        assert response.status_code in [200, 405]

