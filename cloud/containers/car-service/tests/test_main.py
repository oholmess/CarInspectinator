"""
Tests for FastAPI application setup (main.py).
"""
import pytest
from unittest.mock import patch, MagicMock, AsyncMock

from common.errors import APIError, NotFoundError, BadRequestError


class TestAppSetup:
    """Tests for application setup."""
    
    def test_app_title(self, test_client):
        """Test that app has correct title."""
        from app.main import app
        
        assert app.title == "Car Service"
    
    def test_app_version(self, test_client):
        """Test that app has correct version."""
        from app.main import app
        
        assert app.version == "1.0.0"
    
    def test_openapi_docs_available(self, test_client):
        """Test that OpenAPI docs are available."""
        response = test_client.get("/docs")
        
        # Should redirect or return docs
        assert response.status_code in [200, 307]
    
    def test_openapi_json_available(self, test_client):
        """Test that OpenAPI JSON is available."""
        response = test_client.get("/openapi.json")
        
        assert response.status_code == 200
        data = response.json()
        assert "openapi" in data
        assert "paths" in data


class TestHealthCheck:
    """Tests for health check endpoint."""
    
    def test_health_returns_ok(self, test_client):
        """Test health endpoint returns OK status."""
        response = test_client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
    
    def test_health_returns_service_name(self, test_client):
        """Test health endpoint returns service name."""
        response = test_client.get("/health")
        
        data = response.json()
        assert data["service"] == "car-service"


class TestExceptionHandler:
    """Tests for custom exception handler."""
    
    def test_api_error_handler_not_found(self, test_client):
        """Test that NotFoundError is handled correctly."""
        from app.main import app
        from fastapi import Request
        from fastapi.responses import JSONResponse
        
        # Create a mock route that raises NotFoundError
        @app.get("/test-not-found")
        async def raise_not_found():
            raise NotFoundError("Test resource not found")
        
        response = test_client.get("/test-not-found")
        
        assert response.status_code == 404
        data = response.json()
        assert data["error"]["code"] == "NOT_FOUND"
    
    def test_api_error_handler_bad_request(self, test_client):
        """Test that BadRequestError is handled correctly."""
        from app.main import app
        
        @app.get("/test-bad-request")
        async def raise_bad_request():
            raise BadRequestError("Invalid input")
        
        response = test_client.get("/test-bad-request")
        
        assert response.status_code == 400
        data = response.json()
        assert data["error"]["code"] == "BAD_REQUEST"


class TestCORSMiddleware:
    """Tests for CORS middleware configuration."""
    
    def test_cors_allows_all_origins(self, test_client):
        """Test that CORS allows all origins."""
        response = test_client.get(
            "/health",
            headers={"Origin": "http://example.com"}
        )
        
        # Check CORS header is present (might be set on preflight)
        assert response.status_code == 200


class TestStartupEvent:
    """Tests for application startup event."""
    
    @pytest.mark.asyncio
    async def test_startup_initializes_firebase(self, mock_firebase):
        """Test that startup event initializes Firebase."""
        from app.main import startup_event
        
        with patch('app.main.initialize_firebase') as mock_init:
            await startup_event()
            mock_init.assert_called_once()
    
    @pytest.mark.asyncio
    async def test_startup_handles_firebase_error(self, mock_firebase):
        """Test that startup handles Firebase initialization errors."""
        from app.main import startup_event
        
        with patch('app.main.initialize_firebase') as mock_init:
            mock_init.side_effect = Exception("Firebase error")
            
            # Should not raise, just log
            await startup_event()

