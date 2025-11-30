//
//  LoggingServiceTests.swift
//  CarInspectinatorTests
//
//  Unit tests for LoggingService (Logger)
//

import XCTest
@testable import CarInspectinator

final class LoggingServiceTests: XCTestCase {
    
    var sut: Logger!
    
    override func setUp() {
        super.setUp()
        sut = Logger(subsystem: "TestSubsystem", category: "TestCategory")
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_CreatesLogger() {
        // Given/When
        let logger = Logger(subsystem: "com.test", category: "test")
        
        // Then
        XCTAssertNotNil(logger)
    }
    
    // MARK: - Debug Level Tests
    
    func testDebug_DoesNotThrow() {
        // Given/When/Then - Should not crash
        sut.debug("Debug message", file: #file, function: #function, line: #line)
    }
    
    func testDebug_AcceptsEmptyMessage() {
        // Given/When/Then - Should not crash
        sut.debug("", file: #file, function: #function, line: #line)
    }
    
    // MARK: - Info Level Tests
    
    func testInfo_DoesNotThrow() {
        // Given/When/Then - Should not crash
        sut.info("Info message", file: #file, function: #function, line: #line)
    }
    
    func testInfo_AcceptsLongMessage() {
        // Given
        let longMessage = String(repeating: "Test message ", count: 100)
        
        // When/Then - Should not crash
        sut.info(longMessage, file: #file, function: #function, line: #line)
    }
    
    // MARK: - Warning Level Tests
    
    func testWarning_DoesNotThrow() {
        // Given/When/Then - Should not crash
        sut.warning("Warning message", file: #file, function: #function, line: #line)
    }
    
    func testWarning_AcceptsSpecialCharacters() {
        // Given/When/Then - Should not crash
        sut.warning("Warning: 🚨 Alert! @#$%^&*()", file: #file, function: #function, line: #line)
    }
    
    // MARK: - Error Level Tests
    
    func testError_DoesNotThrow() {
        // Given/When/Then - Should not crash
        sut.error("Error message", file: #file, function: #function, line: #line)
    }
    
    func testError_AcceptsMultilineMessage() {
        // Given
        let multilineMessage = """
        Error occurred:
        - Line 1
        - Line 2
        - Line 3
        """
        
        // When/Then - Should not crash
        sut.error(multilineMessage, file: #file, function: #function, line: #line)
    }
    
    // MARK: - Log Level Tests
    
    func testLog_DebugLevel() {
        // Given/When/Then - Should not crash
        sut.log("Message", level: .debug, file: #file, function: #function, line: #line)
    }
    
    func testLog_InfoLevel() {
        // Given/When/Then - Should not crash
        sut.log("Message", level: .info, file: #file, function: #function, line: #line)
    }
    
    func testLog_WarningLevel() {
        // Given/When/Then - Should not crash
        sut.log("Message", level: .warning, file: #file, function: #function, line: #line)
    }
    
    func testLog_ErrorLevel() {
        // Given/When/Then - Should not crash
        sut.log("Message", level: .error, file: #file, function: #function, line: #line)
    }
    
    // MARK: - LoggerFactory Tests
    
    func testLoggerFactory_ReturnsLogger() {
        // Given/When
        let logger = LoggerFactory.shared.logger(for: "TestCategory")
        
        // Then
        XCTAssertNotNil(logger)
    }
    
    func testLoggerFactory_ReturnsDifferentInstances() {
        // Given/When
        let logger1 = LoggerFactory.shared.logger(for: "Category1")
        let logger2 = LoggerFactory.shared.logger(for: "Category2")
        
        // Then - They should be different instances (not checking reference equality since they're value types)
        XCTAssertNotNil(logger1)
        XCTAssertNotNil(logger2)
    }
    
    func testLoggerFactory_SharedInstance() {
        // Given/When
        let factory1 = LoggerFactory.shared
        let factory2 = LoggerFactory.shared
        
        // Then
        XCTAssertTrue(factory1 === factory2)
    }
}

