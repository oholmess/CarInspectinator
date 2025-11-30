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
    
    // MARK: - getCars Tests
    
    func testGetCars_Success() async throws {
        // Given
        let expectedCars = createMockCars()
        let jsonData = try JSONEncoder().encode(expectedCars)
        mockNetworkHandler.mockData = jsonData
        
        // When
        let cars = try await sut.getCars()
        
        // Then
        XCTAssertEqual(cars.count, expectedCars.count)
        XCTAssertEqual(mockNetworkHandler.requestCallCount, 1)
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Fetching all cars", level: .info))
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Successfully fetched data", level: .debug))
    }
    
    func testGetCars_NetworkError() async {
        // Given
        mockNetworkHandler.shouldThrowError = true
        mockNetworkHandler.mockError = NetworkError.noResponse
        
        // When/Then
        do {
            _ = try await sut.getCars()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
            XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Failed to fetch data", level: .error))
        }
    }
    
    func testGetCars_DecodingError() async {
        // Given
        mockNetworkHandler.mockData = "invalid json".data(using: .utf8)
        
        // When/Then
        do {
            _ = try await sut.getCars()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Failed to fetch data", level: .error))
        }
    }
    
    // MARK: - getCar Tests
    
    func testGetCar_Success() async throws {
        // Given
        let expectedCar = createMockCar(id: "test-car-123")
        let jsonData = try JSONEncoder().encode(expectedCar)
        mockNetworkHandler.mockData = jsonData
        
        // When
        let car = try await sut.getCar("test-car-123")
        
        // Then
        XCTAssertEqual(car.id, expectedCar.id)
        XCTAssertEqual(mockNetworkHandler.requestCallCount, 1)
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Fetching car with ID: test-car-123", level: .info))
    }
    
    func testGetCar_NetworkError() async {
        // Given
        mockNetworkHandler.shouldThrowError = true
        mockNetworkHandler.mockError = NetworkError.failedStatusCode("404 Not Found")
        
        // When/Then
        do {
            _ = try await sut.getCar("nonexistent")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockCars() -> [Car] {
        return [
            createMockCar(id: "car1"),
            createMockCar(id: "car2"),
            createMockCar(id: "car3")
        ]
    }
    
    private func createMockCar(id: String) -> Car {
        return Car(
            id: id,
            make: "TestMake",
            model: "TestModel",
            blurb: "Test description",
            iconAssetName: "test_icon",
            year: 2024,
            bodyStyle: "Sedan",
            exteriorColor: "Blue",
            interiorColor: "Black",
            interiorPanoramaAssetName: nil,
            volumeId: "test-volume",
            modelUrl: nil,
            engine: nil,
            performance: nil,
            dimensions: nil,
            drivetrain: nil,
            otherSpecs: nil
        )
    }
}
