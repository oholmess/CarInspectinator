//
//  CarModelTests.swift
//  CarInspectinatorTests
//
//  Unit tests for Car model and related types
//

import XCTest
@testable import CarInspectinator

final class CarModelTests: XCTestCase {
    
    // MARK: - Car Initialization Tests
    
    func testCar_InitWithRequiredFields() {
        // Given/When
        let car = Car(make: "BMW", model: "M3")
        
        // Then
        XCTAssertEqual(car.make, "BMW")
        XCTAssertEqual(car.model, "M3")
        XCTAssertNotNil(car.id)
    }
    
    func testCar_InitWithAllFields() {
        // Given
        let id = UUID()
        
        // When
        let car = Car(
            id: id,
            make: "BMW",
            model: "M3",
            blurb: "A sporty sedan",
            iconAssetName: "bmw_m3",
            year: 2024,
            bodyStyle: .sedan,
            exteriorColor: "Alpine White",
            interiorColor: "Black",
            interiorPanoramaAssetName: "bmw_m3_pano",
            volumeId: "bmw_m3_vol",
            modelUrl: "https://example.com/model.usdz",
            engine: nil,
            performance: nil,
            dimensions: nil,
            drivetrain: nil,
            otherSpecs: ["feature": "value"]
        )
        
        // Then
        XCTAssertEqual(car.id, id)
        XCTAssertEqual(car.make, "BMW")
        XCTAssertEqual(car.model, "M3")
        XCTAssertEqual(car.blurb, "A sporty sedan")
        XCTAssertEqual(car.iconAssetName, "bmw_m3")
        XCTAssertEqual(car.year, 2024)
        XCTAssertEqual(car.bodyStyle, .sedan)
        XCTAssertEqual(car.exteriorColor, "Alpine White")
        XCTAssertEqual(car.interiorColor, "Black")
        XCTAssertEqual(car.otherSpecs["feature"], "value")
    }
    
    func testCar_DefaultOtherSpecsIsEmpty() {
        // Given/When
        let car = Car(make: "Toyota", model: "Camry")
        
        // Then
        XCTAssertTrue(car.otherSpecs.isEmpty)
    }
    
    // MARK: - Display Name Tests
    
    func testCar_DisplayName_WithYear() {
        // Given
        let car = Car(make: "BMW", model: "M3", year: 2024)
        
        // When
        let displayName = car.displayName
        
        // Then
        XCTAssertEqual(displayName, "2024 BMW M3")
    }
    
    func testCar_DisplayName_WithoutYear() {
        // Given
        let car = Car(make: "BMW", model: "M3")
        
        // When
        let displayName = car.displayName
        
        // Then
        XCTAssertEqual(displayName, "BMW M3")
    }
    
    // MARK: - BodyStyle Tests
    
    func testBodyStyle_Sedan() {
        XCTAssertEqual(BodyStyle.sedan.rawValue, "Sedan")
    }
    
    func testBodyStyle_Coupe() {
        XCTAssertEqual(BodyStyle.coupe.rawValue, "Coupe")
    }
    
    func testBodyStyle_SUV() {
        XCTAssertEqual(BodyStyle.suv.rawValue, "SUV")
    }
    
    func testBodyStyle_Hatchback() {
        XCTAssertEqual(BodyStyle.hatchback.rawValue, "Hatchback")
    }
    
    func testBodyStyle_Wagon() {
        XCTAssertEqual(BodyStyle.wagon.rawValue, "Wagon")
    }
    
    func testBodyStyle_Truck() {
        XCTAssertEqual(BodyStyle.truck.rawValue, "Truck")
    }
    
    // MARK: - Equatable Tests
    
    func testCar_Equatable_SameId() {
        // Given
        let id = UUID()
        let car1 = Car(id: id, make: "BMW", model: "M3")
        let car2 = Car(id: id, make: "BMW", model: "M3")
        
        // Then
        XCTAssertEqual(car1, car2)
    }
    
    func testCar_Equatable_DifferentId() {
        // Given
        let car1 = Car(make: "BMW", model: "M3")
        let car2 = Car(make: "BMW", model: "M3")
        
        // Then
        XCTAssertNotEqual(car1, car2)
    }
    
    // MARK: - Hashable Tests
    
    func testCar_Hashable() {
        // Given
        let car = Car(make: "BMW", model: "M3")
        var set = Set<Car>()
        
        // When
        set.insert(car)
        
        // Then
        XCTAssertTrue(set.contains(car))
    }
    
    // MARK: - AnyCodable Tests
    
    func testAnyCodable_InitWithString() {
        // Given/When
        let anyCodable = AnyCodable("test string")
        
        // Then
        XCTAssertEqual(anyCodable.stringValue, "test string")
    }
    
    func testAnyCodable_InitWithInt() {
        // Given/When
        let anyCodable = AnyCodable(42)
        
        // Then
        XCTAssertEqual(anyCodable.intValue, 42)
    }
    
    func testAnyCodable_InitWithDouble() {
        // Given/When
        let anyCodable = AnyCodable(3.14)
        
        // Then
        XCTAssertNotNil(anyCodable.doubleValue)
        XCTAssertEqual(anyCodable.doubleValue!, 3.14, accuracy: 0.01)
    }
    
    func testAnyCodable_DoubleValue_FromInt() {
        // Given
        let anyCodable = AnyCodable(42)
        
        // When
        let doubleValue = anyCodable.doubleValue
        
        // Then
        XCTAssertEqual(doubleValue, 42.0)
    }
}
