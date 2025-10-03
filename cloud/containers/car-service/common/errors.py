"""Custom error classes for the API."""

class APIError(Exception):
    """Base class for API errors."""
    status_code = 500
    error_code = "INTERNAL_ERROR"
    message = "An internal error occurred"

    def __init__(self, message: str = None):
        if message:
            self.message = message
        super().__init__(self.message)

    def to_dict(self):
        return {
            "error": {
                "code": self.error_code,
                "message": self.message,
            }
        }


class BadRequestError(APIError):
    """400 Bad Request"""
    status_code = 400
    error_code = "BAD_REQUEST"
    message = "Bad request"


class NotFoundError(APIError):
    """404 Not Found"""
    status_code = 404
    error_code = "NOT_FOUND"
    message = "Resource not found"


class ConflictError(APIError):
    """409 Conflict"""
    status_code = 409
    error_code = "CONFLICT"
    message = "Resource conflict"


class ForbiddenError(APIError):
    """403 Forbidden"""
    status_code = 403
    error_code = "FORBIDDEN"
    message = "Access forbidden"

