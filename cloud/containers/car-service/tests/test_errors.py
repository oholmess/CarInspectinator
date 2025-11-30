"""
Tests for error classes.
"""
import pytest

from common.errors import (
    APIError, BadRequestError, NotFoundError, 
    ConflictError, ForbiddenError
)


class TestAPIError:
    """Tests for base APIError class."""
    
    def test_default_values(self):
        """Test APIError default values."""
        error = APIError()
        
        assert error.status_code == 500
        assert error.error_code == "INTERNAL_ERROR"
        assert error.message == "An internal error occurred"
    
    def test_custom_message(self):
        """Test APIError with custom message."""
        error = APIError("Custom error message")
        
        assert error.message == "Custom error message"
    
    def test_to_dict(self):
        """Test APIError to_dict method."""
        error = APIError("Test message")
        result = error.to_dict()
        
        assert "error" in result
        assert result["error"]["code"] == "INTERNAL_ERROR"
        assert result["error"]["message"] == "Test message"
    
    def test_is_exception(self):
        """Test that APIError is an Exception."""
        error = APIError()
        
        assert isinstance(error, Exception)


class TestBadRequestError:
    """Tests for BadRequestError class."""
    
    def test_default_values(self):
        """Test BadRequestError default values."""
        error = BadRequestError()
        
        assert error.status_code == 400
        assert error.error_code == "BAD_REQUEST"
        assert error.message == "Bad request"
    
    def test_custom_message(self):
        """Test BadRequestError with custom message."""
        error = BadRequestError("Invalid input provided")
        
        assert error.message == "Invalid input provided"
    
    def test_to_dict(self):
        """Test BadRequestError to_dict method."""
        error = BadRequestError("Missing required field")
        result = error.to_dict()
        
        assert result["error"]["code"] == "BAD_REQUEST"
        assert result["error"]["message"] == "Missing required field"
    
    def test_inherits_from_api_error(self):
        """Test that BadRequestError inherits from APIError."""
        error = BadRequestError()
        
        assert isinstance(error, APIError)


class TestNotFoundError:
    """Tests for NotFoundError class."""
    
    def test_default_values(self):
        """Test NotFoundError default values."""
        error = NotFoundError()
        
        assert error.status_code == 404
        assert error.error_code == "NOT_FOUND"
        assert error.message == "Resource not found"
    
    def test_custom_message(self):
        """Test NotFoundError with custom message."""
        error = NotFoundError("Car not found")
        
        assert error.message == "Car not found"
    
    def test_to_dict(self):
        """Test NotFoundError to_dict method."""
        error = NotFoundError("Item with ID 123 not found")
        result = error.to_dict()
        
        assert result["error"]["code"] == "NOT_FOUND"
        assert result["error"]["message"] == "Item with ID 123 not found"


class TestConflictError:
    """Tests for ConflictError class."""
    
    def test_default_values(self):
        """Test ConflictError default values."""
        error = ConflictError()
        
        assert error.status_code == 409
        assert error.error_code == "CONFLICT"
        assert error.message == "Resource conflict"
    
    def test_custom_message(self):
        """Test ConflictError with custom message."""
        error = ConflictError("Car already exists")
        
        assert error.message == "Car already exists"


class TestForbiddenError:
    """Tests for ForbiddenError class."""
    
    def test_default_values(self):
        """Test ForbiddenError default values."""
        error = ForbiddenError()
        
        assert error.status_code == 403
        assert error.error_code == "FORBIDDEN"
        assert error.message == "Access forbidden"
    
    def test_custom_message(self):
        """Test ForbiddenError with custom message."""
        error = ForbiddenError("You don't have permission to access this resource")
        
        assert error.message == "You don't have permission to access this resource"


class TestErrorRaising:
    """Tests for raising and catching errors."""
    
    def test_raise_bad_request(self):
        """Test raising BadRequestError."""
        with pytest.raises(BadRequestError) as exc_info:
            raise BadRequestError("Test bad request")
        
        assert exc_info.value.status_code == 400
    
    def test_raise_not_found(self):
        """Test raising NotFoundError."""
        with pytest.raises(NotFoundError) as exc_info:
            raise NotFoundError("Test not found")
        
        assert exc_info.value.status_code == 404
    
    def test_catch_as_api_error(self):
        """Test catching specific errors as APIError."""
        with pytest.raises(APIError):
            raise NotFoundError("Test")
    
    def test_error_string_representation(self):
        """Test error string representation."""
        error = NotFoundError("Car not found")
        
        assert str(error) == "Car not found"

