//
//  ErrorHandlerTests.swift
//  CarInspectinatorTests
//
//  Unit tests for ErrorHandler and error extensions
//

import XCTest
@testable import CarInspectinator

final class ErrorHandlerTests: XCTestCase {
    
    var sut: ErrorHandler!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        sut = ErrorHandler(logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - NetworkError UserFacingError Tests
    
    func testNetworkError_UserError_Title() {
        let error = NetworkError.userError("User made an error")
        XCTAssertEqual(error.title, "Network Error")
    }
    
    func testNetworkError_UserError_Message() {
        let error = NetworkError.userError("Custom message")
        XCTAssertEqual(error.message, "Custom message")
    }
    
    func testNetworkError_DataError_Title() {
        let error = NetworkError.dataError("Data issue")
        XCTAssertEqual(error.title, "Network Error")
    }
    
    func testNetworkError_DataError_Message() {
        let error = NetworkError.dataError("Custom data message")
        XCTAssertEqual(error.message, "Custom data message")
    }
    
    func testNetworkError_EncodingError_Title() {
        let error = NetworkError.encodingError
        XCTAssertEqual(error.title, "Data Error")
    }
    
    func testNetworkError_EncodingError_Message() {
        let error = NetworkError.encodingError
        XCTAssertEqual(error.message, "Failed to encode request data")
    }
    
    func testNetworkError_DecodingError_Title() {
        let error = NetworkError.decodingError
        XCTAssertEqual(error.title, "Data Error")
    }
    
    func testNetworkError_DecodingError_Message() {
        let error = NetworkError.decodingError
        XCTAssertEqual(error.message, "Failed to decode response data")
    }
    
    func testNetworkError_FailedStatusCode_Title() {
        let error = NetworkError.failedStatusCode("500")
        XCTAssertEqual(error.title, "Server Error")
    }
    
    func testNetworkError_FailedStatusCode_Message() {
        let error = NetworkError.failedStatusCode("Internal Server Error")
        XCTAssertEqual(error.message, "Internal Server Error")
    }
    
    func testNetworkError_FailedStatusCodeResponseData_Title() {
        let error = NetworkError.failedStatusCodeResponseData(500, Data())
        XCTAssertEqual(error.title, "Server Error")
    }
    
    func testNetworkError_FailedStatusCodeResponseData_Message() {
        let error = NetworkError.failedStatusCodeResponseData(404, Data())
        XCTAssertEqual(error.message, "Server returned status code: 404")
    }
    
    func testNetworkError_NoResponse_Title() {
        let error = NetworkError.noResponse
        XCTAssertEqual(error.title, "Connection Error")
    }
    
    func testNetworkError_NoResponse_Message() {
        let error = NetworkError.noResponse
        XCTAssertEqual(error.message, "No response received from server")
    }
    
    // MARK: - NetworkError RecoverySuggestion Tests
    
    func testNetworkError_NoResponse_RecoverySuggestion() {
        let error = NetworkError.noResponse
        XCTAssertEqual(error.recoverySuggestion, "Check your internet connection and try again")
    }
    
    func testNetworkError_FailedStatusCode500_RecoverySuggestion() {
        let error = NetworkError.failedStatusCodeResponseData(500, Data())
        XCTAssertEqual(error.recoverySuggestion, "Server is experiencing issues. Please try again later")
    }
    
    func testNetworkError_FailedStatusCode503_RecoverySuggestion() {
        let error = NetworkError.failedStatusCodeResponseData(503, Data())
        XCTAssertEqual(error.recoverySuggestion, "Server is experiencing issues. Please try again later")
    }
    
    func testNetworkError_FailedStatusCode400_RecoverySuggestion() {
        let error = NetworkError.failedStatusCodeResponseData(400, Data())
        XCTAssertEqual(error.recoverySuggestion, "Request was invalid. Please try again")
    }
    
    func testNetworkError_FailedStatusCode404_RecoverySuggestion() {
        let error = NetworkError.failedStatusCodeResponseData(404, Data())
        XCTAssertEqual(error.recoverySuggestion, "Request was invalid. Please try again")
    }
    
    func testNetworkError_FailedStatusCode300_RecoverySuggestion() {
        let error = NetworkError.failedStatusCodeResponseData(300, Data())
        XCTAssertNil(error.recoverySuggestion)
    }
    
    func testNetworkError_Default_RecoverySuggestion() {
        let error = NetworkError.userError("test")
        XCTAssertEqual(error.recoverySuggestion, "Please try again")
    }
    
    func testNetworkError_EncodingError_RecoverySuggestion() {
        let error = NetworkError.encodingError
        XCTAssertEqual(error.recoverySuggestion, "Please try again")
    }
    
    func testNetworkError_DecodingError_RecoverySuggestion() {
        let error = NetworkError.decodingError
        XCTAssertEqual(error.recoverySuggestion, "Please try again")
    }
    
    // MARK: - ConfigurationError UserFacingError Tests
    
    func testConfigurationError_Title() {
        let error = ConfigurationError.nilObject
        XCTAssertEqual(error.title, "Configuration Error")
    }
    
    func testConfigurationError_NilObject_Message() {
        let error = ConfigurationError.nilObject
        XCTAssertEqual(error.message, "Required configuration is missing")
    }
    
    func testConfigurationError_RecoverySuggestion() {
        let error = ConfigurationError.nilObject
        XCTAssertEqual(error.recoverySuggestion, "Please restart the app or contact support")
    }
    
    // MARK: - ErrorHandler.handle Tests
    
    func testHandle_LogsError() {
        // Given
        let error = NetworkError.noResponse
        
        // When
        sut.handle(error, context: "TestContext")
        
        // Then
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "[TestContext]", level: .error))
    }
    
    func testHandle_FailedStatusCodeResponseData_LogsDetails() {
        // Given
        let responseData = "Error response body".data(using: .utf8)!
        let error = NetworkError.failedStatusCodeResponseData(500, responseData)
        
        // When
        sut.handle(error, context: "APICall")
        
        // Then
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "[APICall]", level: .error))
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Response body:", level: .debug))
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Status code: 500", level: .debug))
    }
    
    // MARK: - ErrorHandler.userFacingMessage Tests
    
    func testUserFacingMessage_NetworkError() {
        // Given
        let error = NetworkError.noResponse
        
        // When
        let result = sut.userFacingMessage(for: error)
        
        // Then
        XCTAssertEqual(result.title, "Connection Error")
        XCTAssertEqual(result.message, "No response received from server")
        XCTAssertEqual(result.suggestion, "Check your internet connection and try again")
    }
    
    func testUserFacingMessage_ConfigurationError() {
        // Given
        let error = ConfigurationError.nilObject
        
        // When
        let result = sut.userFacingMessage(for: error)
        
        // Then
        XCTAssertEqual(result.title, "Configuration Error")
        XCTAssertEqual(result.message, "Required configuration is missing")
        XCTAssertEqual(result.suggestion, "Please restart the app or contact support")
    }
    
    func testUserFacingMessage_UnknownError() {
        // Given
        struct UnknownError: Error {}
        let error = UnknownError()
        
        // When
        let result = sut.userFacingMessage(for: error)
        
        // Then
        XCTAssertEqual(result.title, "Error")
        XCTAssertEqual(result.suggestion, "If the problem persists, please contact support")
    }
    
    // MARK: - NetworkError statusCodeResponseData Tests
    
    func testStatusCodeResponseData_ReturnsData() {
        // Given
        let data = "test".data(using: .utf8)!
        let error = NetworkError.failedStatusCodeResponseData(404, data)
        
        // When
        let result = error.statusCodeResponseData
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.0, 404)
        XCTAssertEqual(result?.1, data)
    }
    
    func testStatusCodeResponseData_ReturnsNilForOtherErrors() {
        // Given
        let error = NetworkError.noResponse
        
        // When
        let result = error.statusCodeResponseData
        
        // Then
        XCTAssertNil(result)
    }
    
    func testStatusCodeResponseData_ReturnsNilForUserError() {
        let error = NetworkError.userError("test")
        XCTAssertNil(error.statusCodeResponseData)
    }
    
    func testStatusCodeResponseData_ReturnsNilForDataError() {
        let error = NetworkError.dataError("test")
        XCTAssertNil(error.statusCodeResponseData)
    }
    
    func testStatusCodeResponseData_ReturnsNilForEncodingError() {
        let error = NetworkError.encodingError
        XCTAssertNil(error.statusCodeResponseData)
    }
    
    func testStatusCodeResponseData_ReturnsNilForDecodingError() {
        let error = NetworkError.decodingError
        XCTAssertNil(error.statusCodeResponseData)
    }
    
    func testStatusCodeResponseData_ReturnsNilForFailedStatusCode() {
        let error = NetworkError.failedStatusCode("test")
        XCTAssertNil(error.statusCodeResponseData)
    }
}

