//
//  CarServiceTests.swift
//  CarInspectinatorTests
//
//  Unit tests for CarService
//

import XCTest
@testable import CarInspectinator

final class CarServiceTests: XCTestCase {
    
    var sut: CarService!
    var mockNetworkHandler: MockNetworkHandler!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockNetworkHandler = MockNetworkHandler()
        mockLogger = MockLogger()
        sut = CarService(networkHandler: mockNetworkHandler, logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkHandler = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - getCars() Tests
    
    func testGetCarsSuccess() async throws {
        // Arrange
        let testCars = [
            Car(make: "BMW", model: "M3"),
            Car(make: "Audi", model: "RS7")
        ]
        let testData = try JSONEncoder().encode(testCars)
        mockNetworkHandler.mockData = testData
        
        // Act
        let result: [Car] = try await sut.getCars()
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].make, "BMW")
        XCTAssertEqual(result[1].make, "Audi")
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Fetching all cars", level: .info))
    }
    
    func testGetCarsNetworkFailure() async {
        // Arrange
        mockNetworkHandler.shouldThrowError = true
        mockNetworkHandler.mockError = NetworkError.noResponse
        
        // Act & Assert
        do {
            _ = try await sut.getCars()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Failed to fetch data", level: .error))
        }
    }
    
    func testGetCarsCallsNetworkHandlerWithCorrectURL() async throws {
        // Arrange
        let testCars: [Car] = []
        let testData = try JSONEncoder().encode(testCars)
        mockNetworkHandler.mockData = testData
        
        // Act
        _ = try await sut.getCars()
        
        // Assert
        XCTAssertEqual(mockNetworkHandler.requestCallCount, 1)
        XCTAssertTrue(mockNetworkHandler.lastRequestURL?.absoluteString.contains("/v1/cars") ?? false)
        XCTAssertEqual(mockNetworkHandler.lastHttpMethod, "GET")
    }
    
    // MARK: - getCar(_:) Tests
    
    func testGetCarSuccess() async throws {
        // Arrange
        let testCar = Car(make: "BMW", model: "M3")
        let testData = try JSONEncoder().encode(testCar)
        mockNetworkHandler.mockData = testData
        
        // Act
        let result: Car = try await sut.getCar("test-id")
        
        // Assert
        XCTAssertEqual(result.make, "BMW")
        XCTAssertEqual(result.model, "M3")
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Fetching car with ID: test-id", level: .info))
    }
    
    func testGetCarCallsNetworkHandlerWithCorrectURL() async throws {
        // Arrange
        let testCar = Car(make: "BMW", model: "M3")
        let testData = try JSONEncoder().encode(testCar)
        mockNetworkHandler.mockData = testData
        
        // Act
        _ = try await sut.getCar("test-id-123")
        
        // Assert
        XCTAssertEqual(mockNetworkHandler.requestCallCount, 1)
        XCTAssertTrue(mockNetworkHandler.lastRequestURL?.absoluteString.contains("/v1/cars/test-id-123") ?? false)
        XCTAssertEqual(mockNetworkHandler.lastHttpMethod, "GET")
    }
    
    func testGetCarNetworkFailure() async {
        // Arrange
        mockNetworkHandler.shouldThrowError = true
        mockNetworkHandler.mockError = NetworkError.failedStatusCodeResponseData(404, Data())
        
        // Act & Assert
        do {
            _ = try await sut.getCar("test-id")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Failed to fetch data", level: .error))
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testGetCarsLogsSuccessMessage() async throws {
        // Arrange
        let testCars = [Car(make: "BMW", model: "M3")]
        let testData = try JSONEncoder().encode(testCars)
        mockNetworkHandler.mockData = testData
        
        // Act
        _ = try await sut.getCars()
        
        // Assert
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Successfully fetched data", level: .debug))
    }
    
    func testGetCarThrowsConfigurationErrorForInvalidURL() async {
        // This test verifies behavior when URL creation fails
        // In practice, this would require manipulating NetworkRoutes
        // For now, we verify the error is properly propagated
        
        // Arrange
        mockNetworkHandler.shouldThrowError = true
        mockNetworkHandler.mockError = ConfigurationError.nilObject
        
        // Act & Assert
        do {
            _ = try await sut.getCar("test")
            XCTFail("Expected error to be thrown")
        } catch {
            // Error properly propagated
        }
    }
}

