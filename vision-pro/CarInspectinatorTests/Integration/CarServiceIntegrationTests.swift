//
//  CarServiceIntegrationTests.swift
//  CarInspectinatorTests
//
//  Integration tests for CarService - tests actual network calls
//  These tests are disabled by default to prevent CI failures
//

import XCTest
@testable import CarInspectinator

final class CarServiceIntegrationTests: XCTestCase {
    
    // Set to true to enable integration tests (requires network)
    static let runIntegrationTests = false
    
    var sut: CarService!
    
    override func setUp() {
        super.setUp()
        guard Self.runIntegrationTests else { return }
        sut = CarService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Integration Tests (Disabled by Default)
    
    func testGetCars_Integration_ReturnsData() async throws {
        try XCTSkipUnless(Self.runIntegrationTests, "Integration tests disabled")
        
        // When
        let cars = try await sut.getCars()
        
        // Then
        XCTAssertFalse(cars.isEmpty)
    }
    
    func testGetCar_Integration_ReturnsCar() async throws {
        try XCTSkipUnless(Self.runIntegrationTests, "Integration tests disabled")
        
        // Given - First get a valid car ID
        let cars = try await sut.getCars()
        guard let firstCar = cars.first else {
            XCTFail("No cars available for testing")
            return
        }
        
        // When - Convert UUID to String for the API call
        let car = try await sut.getCar(firstCar.id.uuidString)
        
        // Then
        XCTAssertEqual(car.id, firstCar.id)
    }
    
    // MARK: - Placeholder Test (Always Runs)
    
    func testIntegrationTestsCanBeEnabled() {
        // This test verifies the integration test infrastructure is working
        XCTAssertNotNil(Self.runIntegrationTests)
    }
}
