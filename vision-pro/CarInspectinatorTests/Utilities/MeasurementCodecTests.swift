//
//  MeasurementCodecTests.swift
//  CarInspectinatorTests
//
//  Unit tests for MeasurementCodec
//

import XCTest
@testable import CarInspectinator

final class MeasurementCodecTests: XCTestCase {
    
    // MARK: - Volume Tests
    
    func testDecodeVolumeInLiters() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(2.0),
            "unit": AnyCodable("liters")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: VolumeUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 2.0)
        XCTAssertEqual(result?.unit, .liters)
    }
    
    func testDecodeVolumeInGallons() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(5.0),
            "unit": AnyCodable("gallons")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: VolumeUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 5.0)
        XCTAssertEqual(result?.unit, .gallons)
    }
    
    func testEncodeVolume() {
        // Arrange
        let measurement = Measurement(value: 2.0, unit: UnitVolume.liters)
        
        // Act
        let result = MeasurementCodec.encode(measurement, mapper: VolumeUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["value"] as? Double, 2.0)
        XCTAssertEqual(result?["unit"] as? String, "liters")
    }
    
    // MARK: - Power Tests
    
    func testDecodePowerInHorsepower() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(300.0),
            "unit": AnyCodable("horsepower")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: PowerUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 300.0)
        XCTAssertEqual(result?.unit, .horsepower)
    }
    
    func testDecodePowerInKilowatts() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(224.0),
            "unit": AnyCodable("kilowatts")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: PowerUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 224.0)
        XCTAssertEqual(result?.unit, .kilowatts)
    }
    
    // MARK: - Torque Tests
    
    func testDecodeTorqueInNewtonMeters() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(400.0),
            "unit": AnyCodable("newtonMeters")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: TorqueUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 400.0)
        XCTAssertEqual(result?.unit, .newtonMeters)
    }
    
    func testDecodeTorqueInPoundForceFeet() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(295.0),
            "unit": AnyCodable("poundForceFeet")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: TorqueUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 295.0)
        XCTAssertEqual(result?.unit, .poundForceFeet)
    }
    
    // MARK: - Speed Tests
    
    func testDecodeSpeedInMPH() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(155.0),
            "unit": AnyCodable("milesPerHour")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: SpeedUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 155.0)
        XCTAssertEqual(result?.unit, .milesPerHour)
    }
    
    // MARK: - Length Tests
    
    func testDecodeLengthInInches() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(168.0),
            "unit": AnyCodable("inches")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: LengthUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 168.0)
        XCTAssertEqual(result?.unit, .inches)
    }
    
    func testDecodeLengthInMeters() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(4.27),
            "unit": AnyCodable("meters")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: LengthUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 4.27)
        XCTAssertEqual(result?.unit, .meters)
    }
    
    // MARK: - Mass Tests
    
    func testDecodeMassInPounds() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(3128.0),
            "unit": AnyCodable("pounds")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: MassUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 3128.0)
        XCTAssertEqual(result?.unit, .pounds)
    }
    
    func testDecodeMassInKilograms() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(1419.0),
            "unit": AnyCodable("kilograms")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: MassUnitMapper.self)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 1419.0)
        XCTAssertEqual(result?.unit, .kilograms)
    }
    
    // MARK: - Edge Cases
    
    func testDecodeWithMissingValue() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "unit": AnyCodable("liters")
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: VolumeUnitMapper.self)
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testDecodeWithMissingUnit() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(2.0)
        ]
        
        // Act
        let result = MeasurementCodec.decode(dict, mapper: VolumeUnitMapper.self)
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testDecodeNilDictionary() {
        // Act
        let result = MeasurementCodec.decode(nil, mapper: VolumeUnitMapper.self)
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testEncodeNilMeasurement() {
        // Act
        let result: [String: Any]? = MeasurementCodec.encode(nil as Measurement<UnitVolume>?, mapper: VolumeUnitMapper.self)
        
        // Assert
        XCTAssertNil(result)
    }
    
    // MARK: - Fixed Unit Tests
    
    func testDecodeFixedUnit() {
        // Arrange
        let dict: [String: AnyCodable] = [
            "value": AnyCodable(5.5),
            "unit": AnyCodable("seconds")
        ]
        
        // Act
        let result = MeasurementCodec.decodeFixedUnit(dict, unit: UnitDuration.seconds)
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 5.5)
        XCTAssertEqual(result?.unit, .seconds)
    }
    
    func testEncodeFixedUnit() {
        // Arrange
        let measurement = Measurement(value: 5.5, unit: UnitDuration.seconds)
        
        // Act
        let result = MeasurementCodec.encodeFixedUnit(measurement, unitString: "seconds")
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["value"] as? Double, 5.5)
        XCTAssertEqual(result?["unit"] as? String, "seconds")
    }
}

