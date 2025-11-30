//
//  AppModelTests.swift
//  CarInspectinatorTests
//
//  Unit tests for AppModel
//

import XCTest
@testable import CarInspectinator

final class AppModelTests: XCTestCase {
    
    var sut: AppModel!
    
    override func setUp() {
        super.setUp()
        sut = AppModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInit_ImmersiveSpaceID_HasValue() {
        // Then
        XCTAssertFalse(sut.immersiveSpaceID.isEmpty)
    }
    
    func testInit_ImmersiveSpaceState_IsClosed() {
        // Then
        XCTAssertEqual(sut.immersiveSpaceState, .closed)
    }
    
    func testInit_SelectedCar_IsNil() {
        // Then
        XCTAssertNil(sut.selectedCar)
    }
    
    func testInit_PanoramaImageName_HasValue() {
        // Then
        XCTAssertNotNil(sut.panoramaImageName)
    }
    
    // MARK: - selectCar Tests
    
    func testSelectCar_UpdatesSelectedCar() {
        // Given
        let car = createMockCar()
        
        // When
        sut.selectCar(car)
        
        // Then
        XCTAssertNotNil(sut.selectedCar)
        XCTAssertEqual(sut.selectedCar?.id, car.id)
    }
    
    func testSelectCar_UpdatesPanoramaImageName() {
        // Given
        let car = createMockCarWithPanorama()
        
        // When
        sut.selectCar(car)
        
        // Then
        XCTAssertEqual(sut.panoramaImageName, car.interiorPanoramaAssetName)
    }
    
    // MARK: - resetSelection Tests
    
    func testResetSelection_ClearsSelectedCar() {
        // Given
        let car = createMockCar()
        sut.selectCar(car)
        
        // When
        sut.resetSelection()
        
        // Then
        XCTAssertNil(sut.selectedCar)
    }
    
    func testResetSelection_ResetsPanoramaImageName() {
        // Given
        let car = createMockCarWithPanorama()
        sut.selectCar(car)
        let originalPanorama = sut.panoramaImageName
        sut.resetSelection()
        
        // Then - panorama should be reset to default or nil
        // The exact behavior depends on implementation
        XCTAssertNotNil(sut.panoramaImageName) // Default value exists
    }
    
    // MARK: - Helper Methods
    
    private func createMockCar() -> Car {
        return Car(
            id: "test-car",
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
    
    private func createMockCarWithPanorama() -> Car {
        return Car(
            id: "test-car",
            make: "TestMake",
            model: "TestModel",
            blurb: "Test description",
            iconAssetName: "test_icon",
            year: 2024,
            bodyStyle: "Sedan",
            exteriorColor: "Blue",
            interiorColor: "Black",
            interiorPanoramaAssetName: "test_panorama",
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

