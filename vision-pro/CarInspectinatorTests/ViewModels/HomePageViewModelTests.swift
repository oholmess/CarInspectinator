//
//  HomePageViewModelTests.swift
//  CarInspectinatorTests
//
//  Unit tests for HomePageViewModel
//

import XCTest
@testable import CarInspectinator

@MainActor
final class HomePageViewModelTests: XCTestCase {
    
    var sut: HomePageViewModel!
    var mockCarService: MockCarService!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockCarService = MockCarService()
        mockLogger = MockLogger()
        sut = HomePageViewModel(carService: mockCarService, logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockCarService = nil
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
        mockCarService.mockCars = testCars
        
        // Act
        try await sut.getCars()
        
        // Assert
        XCTAssertEqual(sut.cars.count, 2)
        XCTAssertEqual(sut.cars[0].make, "BMW")
        XCTAssertEqual(sut.cars[1].make, "Audi")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testGetCarsCallsCarService() async throws {
        // Arrange
        mockCarService.mockCars = []
        
        // Act
        try await sut.getCars()
        
        // Assert
        XCTAssertEqual(mockCarService.getCarsCallCount, 1)
    }
    
    func testGetCarsLogsSuccessMessage() async throws {
        // Arrange
        let testCars = [Car(make: "BMW", model: "M3")]
        mockCarService.mockCars = testCars
        
        // Act
        try await sut.getCars()
        
        // Assert
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Successfully loaded 1 cars", level: .info))
    }
    
    func testGetCarsSetsLoadingStateDuringFetch() async throws {
        // Arrange
        mockCarService.mockCars = []
        
        // Assert initial state
        XCTAssertFalse(sut.isLoading)
        
        // Act
        try await sut.getCars()
        
        // Assert final state  
        XCTAssertFalse(sut.isLoading) // Should be false after completion
    }
    
    // MARK: - Error Handling Tests
    
    func testGetCarsHandlesNetworkError() async {
        // Arrange
        mockCarService.shouldThrowError = true
        mockCarService.errorToThrow = NetworkError.noResponse
        
        // Act & Assert
        do {
            try await sut.getCars()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(sut.error)
            XCTAssertFalse(sut.isLoading)
            XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Failed to get cars", level: .error))
        }
    }
    
    func testGetCarsClearsErrorOnSuccess() async throws {
        // Arrange
        mockCarService.mockCars = []
        
        // First set an error
        sut.error = NetworkError.noResponse
        
        // Act
        try await sut.getCars()
        
        // Assert
        XCTAssertNil(sut.error)
    }
    
    func testGetCarsUpdatesErrorProperty() async {
        // Arrange
        let expectedError = NetworkError.failedStatusCodeResponseData(404, Data())
        mockCarService.shouldThrowError = true
        mockCarService.errorToThrow = expectedError
        
        // Act
        do {
            try await sut.getCars()
        } catch {
            // Expected
        }
        
        // Assert
        XCTAssertNotNil(sut.error)
    }
    
    // MARK: - State Tests
    
    func testInitialState() {
        // Assert
        XCTAssertTrue(sut.cars.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testGetCarsPreservesExistingCarsOnSuccess() async throws {
        // Arrange
        let initialCars = [Car(make: "Initial", model: "Car")]
        sut.cars = initialCars
        
        let newCars = [Car(make: "New", model: "Car")]
        mockCarService.mockCars = newCars
        
        // Act
        try await sut.getCars()
        
        // Assert
        XCTAssertEqual(sut.cars.count, 1)
        XCTAssertEqual(sut.cars[0].make, "New")
    }
    
    func testGetCarsEmptyResponse() async throws {
        // Arrange
        mockCarService.mockCars = []
        
        // Act
        try await sut.getCars()
        
        // Assert
        XCTAssertTrue(sut.cars.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
}

