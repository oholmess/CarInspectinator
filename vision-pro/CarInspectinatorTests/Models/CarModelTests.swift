//
//  CarModelTests.swift
//  CarInspectinatorTests
//
//  Unit tests for Car model and related types
//

import XCTest
@testable import CarInspectinator

final class CarModelTests: XCTestCase {
    
    // MARK: - Car JSON Decoding Tests
    
    func testCar_DecodingFromJSON_BasicFields() throws {
        // Given
        let json = """
        {
            "id": "car-123",
            "make": "BMW",
            "model": "M3",
            "blurb": "A sporty sedan",
            "icon_asset_name": "bmw_m3",
            "year": 2024,
            "body_style": "Sedan",
            "exterior_color": "Alpine White",
            "interior_color": "Black"
        }
        """.data(using: .utf8)!
        
        // When
        let car = try JSONDecoder().decode(Car.self, from: json)
        
        // Then
        XCTAssertEqual(car.id, "car-123")
        XCTAssertEqual(car.make, "BMW")
        XCTAssertEqual(car.model, "M3")
        XCTAssertEqual(car.blurb, "A sporty sedan")
        XCTAssertEqual(car.iconAssetName, "bmw_m3")
        XCTAssertEqual(car.year, 2024)
        XCTAssertEqual(car.bodyStyle, "Sedan")
        XCTAssertEqual(car.exteriorColor, "Alpine White")
        XCTAssertEqual(car.interiorColor, "Black")
    }
    
    func testCar_DecodingFromJSON_OptionalFieldsNil() throws {
        // Given
        let json = """
        {
            "id": "car-123",
            "make": "BMW",
            "model": "M3",
            "blurb": "A sporty sedan",
            "icon_asset_name": "bmw_m3",
            "year": 2024,
            "body_style": "Sedan",
            "exterior_color": "White",
            "interior_color": "Black"
        }
        """.data(using: .utf8)!
        
        // When
        let car = try JSONDecoder().decode(Car.self, from: json)
        
        // Then
        XCTAssertNil(car.interiorPanoramaAssetName)
        XCTAssertNil(car.volumeId)
        XCTAssertNil(car.modelUrl)
        XCTAssertNil(car.engine)
        XCTAssertNil(car.performance)
        XCTAssertNil(car.dimensions)
        XCTAssertNil(car.drivetrain)
        XCTAssertNil(car.otherSpecs)
    }
    
    func testCar_DecodingFromJSON_WithVolumeId() throws {
        // Given
        let json = """
        {
            "id": "car-123",
            "make": "BMW",
            "model": "M3",
            "blurb": "Test",
            "icon_asset_name": "icon",
            "year": 2024,
            "body_style": "Sedan",
            "exterior_color": "White",
            "interior_color": "Black",
            "volume_id": "vol-123"
        }
        """.data(using: .utf8)!
        
        // When
        let car = try JSONDecoder().decode(Car.self, from: json)
        
        // Then
        XCTAssertEqual(car.volumeId, "vol-123")
    }
    
    func testCar_DecodingFromJSON_WithModelUrl() throws {
        // Given
        let json = """
        {
            "id": "car-123",
            "make": "BMW",
            "model": "M3",
            "blurb": "Test",
            "icon_asset_name": "icon",
            "year": 2024,
            "body_style": "Sedan",
            "exterior_color": "White",
            "interior_color": "Black",
            "model_url": "https://example.com/model.usdz"
        }
        """.data(using: .utf8)!
        
        // When
        let car = try JSONDecoder().decode(Car.self, from: json)
        
        // Then
        XCTAssertEqual(car.modelUrl, "https://example.com/model.usdz")
    }
    
    // MARK: - Engine Decoding Tests
    
    func testEngine_DecodingFromJSON() throws {
        // Given
        let json = """
        {
            "type": "V8",
            "displacement": {"value": 4.4, "unit": "liters"},
            "horsepower": {"value": 503, "unit": "hp"},
            "torque": {"value": 479, "unit": "lb-ft"}
        }
        """.data(using: .utf8)!
        
        // When
        let engine = try JSONDecoder().decode(Engine.self, from: json)
        
        // Then
        XCTAssertEqual(engine.type, "V8")
        XCTAssertNotNil(engine.displacement)
        XCTAssertNotNil(engine.horsepower)
        XCTAssertNotNil(engine.torque)
    }
    
    // MARK: - Performance Decoding Tests
    
    func testPerformance_DecodingFromJSON() throws {
        // Given
        let json = """
        {
            "zero_to_sixty": {"value": 3.8, "unit": "seconds"},
            "top_speed": {"value": 155, "unit": "mph"},
            "fuel_economy_city": {"value": 16, "unit": "mpg"},
            "fuel_economy_highway": {"value": 24, "unit": "mpg"}
        }
        """.data(using: .utf8)!
        
        // When
        let performance = try JSONDecoder().decode(Performance.self, from: json)
        
        // Then
        XCTAssertNotNil(performance.zeroToSixty)
        XCTAssertNotNil(performance.topSpeed)
        XCTAssertNotNil(performance.fuelEconomyCity)
        XCTAssertNotNil(performance.fuelEconomyHighway)
    }
    
    // MARK: - Dimensions Decoding Tests
    
    func testDimensions_DecodingFromJSON() throws {
        // Given
        let json = """
        {
            "length": {"value": 188.5, "unit": "inches"},
            "width": {"value": 74.4, "unit": "inches"},
            "height": {"value": 56.4, "unit": "inches"},
            "wheelbase": {"value": 112.5, "unit": "inches"},
            "curb_weight": {"value": 3850, "unit": "lbs"}
        }
        """.data(using: .utf8)!
        
        // When
        let dimensions = try JSONDecoder().decode(Dimensions.self, from: json)
        
        // Then
        XCTAssertNotNil(dimensions.length)
        XCTAssertNotNil(dimensions.width)
        XCTAssertNotNil(dimensions.height)
        XCTAssertNotNil(dimensions.wheelbase)
        XCTAssertNotNil(dimensions.curbWeight)
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
        XCTAssertEqual(anyCodable.stringValue, "42")
    }
    
    func testAnyCodable_InitWithDouble() {
        // Given/When
        let anyCodable = AnyCodable(3.14)
        
        // Then
        XCTAssertNotNil(anyCodable.doubleValue)
        XCTAssertEqual(anyCodable.doubleValue!, 3.14, accuracy: 0.01)
    }
    
    func testAnyCodable_DecodingString() throws {
        // Given
        let json = "\"hello\"".data(using: .utf8)!
        
        // When
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: json)
        
        // Then
        XCTAssertEqual(decoded.stringValue, "hello")
    }
    
    func testAnyCodable_DecodingNumber() throws {
        // Given
        let json = "42".data(using: .utf8)!
        
        // When
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: json)
        
        // Then
        XCTAssertNotNil(decoded.doubleValue)
    }
    
    func testAnyCodable_DecodingBool() throws {
        // Given
        let json = "true".data(using: .utf8)!
        
        // When
        let decoded = try JSONDecoder().decode(AnyCodable.self, from: json)
        
        // Then
        XCTAssertNotNil(decoded)
    }
}

