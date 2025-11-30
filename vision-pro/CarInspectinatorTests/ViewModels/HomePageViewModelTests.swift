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
    
    // MARK: - Initialization Tests
    
    func testInit_CarsIsEmpty() {
        // Then
        XCTAssertTrue(sut.cars.isEmpty)
    }
    
    func testInit_IsLoadingIsFalse() {
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func testInit_ErrorIsNil() {
        // Then
        XCTAssertNil(sut.error)
    }
    
    // MARK: - getCars Tests
    
    func testGetCars_Success_UpdatesCars() async throws {
        // Given
        let expectedCars = createMockCars()
        mockCarService.mockCars = expectedCars
        
        // When
        try await sut.getCars()
        
        // Then
        XCTAssertEqual(sut.cars.count, expectedCars.count)
    }
    
    func testGetCars_Success_SetsLoadingFalse() async throws {
        // Given
        mockCarService.mockCars = createMockCars()
        
        // When
        try await sut.getCars()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func testGetCars_Success_ClearsError() async throws {
        // Given
        mockCarService.mockCars = createMockCars()
        sut.error = NetworkError.noResponse // Set a previous error
        
        // When
        try await sut.getCars()
        
        // Then
        XCTAssertNil(sut.error)
    }
    
    func testGetCars_CallsCarService() async throws {
        // Given
        mockCarService.mockCars = []
        
        // When
        try await sut.getCars()
        
        // Then
        XCTAssertEqual(mockCarService.getCarsCallCount, 1)
    }
    
    func testGetCars_Success_LogsInfo() async throws {
        // Given
        mockCarService.mockCars = createMockCars()
        
        // When
        try await sut.getCars()
        
        // Then
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Successfully loaded", level: .info))
    }
    
    func testGetCars_Error_KeepsCarsEmpty() async {
        // Given
        mockCarService.shouldThrowError = true
        mockCarService.errorToThrow = NetworkError.noResponse
        
        // When
        do {
            try await sut.getCars()
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertTrue(sut.cars.isEmpty)
    }
    
    func testGetCars_Error_SetsLoadingFalse() async {
        // Given
        mockCarService.shouldThrowError = true
        mockCarService.errorToThrow = NetworkError.noResponse
        
        // When
        do {
            try await sut.getCars()
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func testGetCars_Error_SetsError() async {
        // Given
        mockCarService.shouldThrowError = true
        mockCarService.errorToThrow = NetworkError.noResponse
        
        // When
        do {
            try await sut.getCars()
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertNotNil(sut.error)
    }
    
    func testGetCars_Error_LogsError() async {
        // Given
        mockCarService.shouldThrowError = true
        mockCarService.errorToThrow = NetworkError.noResponse
        
        // When
        do {
            try await sut.getCars()
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Failed to get cars", level: .error))
    }
    
    func testGetCars_Error_ThrowsError() async {
        // Given
        mockCarService.shouldThrowError = true
        mockCarService.errorToThrow = NetworkError.noResponse
        
        // When/Then
        do {
            try await sut.getCars()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockCars() -> [Car] {
        return [
            createMockCar(),
            createMockCar(),
            createMockCar()
        ]
    }
    
    private func createMockCar() -> Car {
        return Car(
            id: UUID(),
            make: "TestMake",
            model: "TestModel",
            blurb: "Test description",
            iconAssetName: "test_icon",
            year: 2024,
            bodyStyle: .sedan,
            exteriorColor: "Blue",
            interiorColor: "Black",
            interiorPanoramaAssetName: nil,
            volumeId: "test-volume",
            modelUrl: nil,
            engine: nil,
            performance: nil,
            dimensions: nil,
            drivetrain: nil,
            otherSpecs: [:]
        )
    }
}
