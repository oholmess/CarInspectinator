//
//  ErrorHandler.swift
//  CarInspectinator
//
//  Centralized error handling following Single Responsibility Principle
//

import Foundation

// MARK: - User-Facing Error Messages

protocol UserFacingError: Error {
    var title: String { get }
    var message: String { get }
    var recoverySuggestion: String? { get }
}

// MARK: - Error Extensions

extension NetworkError: UserFacingError {
    var title: String {
        switch self {
        case .userError, .dataError:
            return "Network Error"
        case .encodingError, .decodingError:
            return "Data Error"
        case .failedStatusCode, .failedStatusCodeResponseData:
            return "Server Error"
        case .noResponse:
            return "Connection Error"
        }
    }
    
    var message: String {
        switch self {
        case .userError(let msg), .dataError(let msg), .failedStatusCode(let msg):
            return msg
        case .failedStatusCodeResponseData(let code, _):
            return "Server returned status code: \(code)"
        case .encodingError:
            return "Failed to encode request data"
        case .decodingError:
            return "Failed to decode response data"
        case .noResponse:
            return "No response received from server"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noResponse:
            return "Check your internet connection and try again"
        case .failedStatusCodeResponseData(let code, _):
            if code >= 500 {
                return "Server is experiencing issues. Please try again later"
            } else if code >= 400 {
                return "Request was invalid. Please try again"
            }
            return nil
        default:
            return "Please try again"
        }
    }
}

extension ConfigurationError: UserFacingError {
    var title: String {
        "Configuration Error"
    }
    
    var message: String {
        switch self {
        case .nilObject:
            return "Required configuration is missing"
        }
    }
    
    var recoverySuggestion: String? {
        "Please restart the app or contact support"
    }
}

// MARK: - Error Handler Service

protocol ErrorHandlerProtocol {
    func handle(_ error: Error, context: String)
    func userFacingMessage(for error: Error) -> (title: String, message: String, suggestion: String?)
}

final class ErrorHandler: ErrorHandlerProtocol {
    private let logger: LoggerProtocol
    
    init(logger: LoggerProtocol = LoggerFactory.shared.logger(for: "ErrorHandler")) {
        self.logger = logger
    }
    
    func handle(_ error: Error, context: String) {
        logger.error("[\(context)] \(error.localizedDescription)", file: #file, function: #function, line: #line)
        
        // Log additional details for specific error types
        if let networkError = error as? NetworkError,
           case .failedStatusCodeResponseData(let code, let data) = networkError {
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("Response body: \(responseString)", file: #file, function: #function, line: #line)
            }
            logger.debug("Status code: \(code)", file: #file, function: #function, line: #line)
        }
    }
    
    func userFacingMessage(for error: Error) -> (title: String, message: String, suggestion: String?) {
        if let userError = error as? UserFacingError {
            return (userError.title, userError.message, userError.recoverySuggestion)
        }
        
        // Default fallback for unknown errors
        return (
            "Error",
            error.localizedDescription,
            "If the problem persists, please contact support"
        )
    }
}

