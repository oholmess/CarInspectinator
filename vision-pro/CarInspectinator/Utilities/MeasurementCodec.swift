//
//  MeasurementCodec.swift
//  CarInspectinator
//
//  Utilities for encoding/decoding measurements
//  Follows Single Responsibility and Open/Closed principles
//

import Foundation

// MARK: - Measurement Dictionary Structure

struct MeasurementDict: Codable {
    let value: Double
    let unit: String
    
    enum CodingKeys: String, CodingKey {
        case value, unit
    }
}

// MARK: - Unit Mapping Protocol

protocol UnitMapper {
    associatedtype UnitType: Unit
    static func unit(from string: String) -> UnitType
    static func string(from unit: UnitType) -> String
}

// MARK: - Unit Mappers

struct VolumeUnitMapper: UnitMapper {
    static func unit(from string: String) -> UnitVolume {
        switch string {
        case "gallons": return .gallons
        case "liters": return .liters
        case "milliliters": return .milliliters
        default: return .liters
        }
    }
    
    static func string(from unit: UnitVolume) -> String {
        switch unit {
        case .gallons: return "gallons"
        case .milliliters: return "milliliters"
        default: return "liters"
        }
    }
}

struct PowerUnitMapper: UnitMapper {
    static func unit(from string: String) -> UnitPower {
        switch string {
        case "kilowatts": return .kilowatts
        case "horsepower": return .horsepower
        default: return .horsepower
        }
    }
    
    static func string(from unit: UnitPower) -> String {
        switch unit {
        case .kilowatts: return "kilowatts"
        default: return "horsepower"
        }
    }
}

struct TorqueUnitMapper: UnitMapper {
    static func unit(from string: String) -> UnitTorque {
        switch string {
        case "newtonMeters": return .newtonMeters
        case "poundForceFeet": return .poundForceFeet
        default: return .newtonMeters
        }
    }
    
    static func string(from unit: UnitTorque) -> String {
        switch unit {
        case .newtonMeters: return "newtonMeters"
        default: return "poundForceFeet"
        }
    }
}

struct SpeedUnitMapper: UnitMapper {
    static func unit(from string: String) -> UnitSpeed {
        switch string {
        case "milesPerHour": return .milesPerHour
        case "kilometersPerHour": return .kilometersPerHour
        default: return .kilometersPerHour
        }
    }
    
    static func string(from unit: UnitSpeed) -> String {
        switch unit {
        case .milesPerHour: return "milesPerHour"
        default: return "kilometersPerHour"
        }
    }
}

struct FuelEfficiencyUnitMapper: UnitMapper {
    static func unit(from string: String) -> UnitFuelEfficiency {
        switch string {
        case "litersPer100km": return .litersPer100Kilometers
        case "milesPerGallon": return .milesPerGallon
        default: return .milesPerGallon
        }
    }
    
    static func string(from unit: UnitFuelEfficiency) -> String {
        switch unit {
        case .litersPer100Kilometers: return "litersPer100km"
        default: return "milesPerGallon"
        }
    }
}

struct LengthUnitMapper: UnitMapper {
    static func unit(from string: String) -> UnitLength {
        switch string {
        case "millimeters": return .millimeters
        case "centimeters": return .centimeters
        case "meters": return .meters
        case "inches": return .inches
        default: return .inches
        }
    }
    
    static func string(from unit: UnitLength) -> String {
        switch unit {
        case .millimeters: return "millimeters"
        case .centimeters: return "centimeters"
        case .meters: return "meters"
        default: return "inches"
        }
    }
}

struct MassUnitMapper: UnitMapper {
    static func unit(from string: String) -> UnitMass {
        switch string {
        case "kilograms": return .kilograms
        case "pounds": return .pounds
        default: return .pounds
        }
    }
    
    static func string(from unit: UnitMass) -> String {
        switch unit {
        case .kilograms: return "kilograms"
        default: return "pounds"
        }
    }
}

// MARK: - Generic Measurement Codec

struct MeasurementCodec {
    /// Decode a measurement from a dictionary
    static func decode<U, M>(_ dict: [String: AnyCodable]?, mapper: M.Type) -> Measurement<U>? 
    where U: Unit, M: UnitMapper, M.UnitType == U {
        guard let dict = dict,
              let value = dict["value"]?.doubleValue,
              let unitString = dict["unit"]?.stringValue else {
            return nil
        }
        let unit = M.unit(from: unitString)
        return Measurement(value: value, unit: unit)
    }
    
    /// Encode a measurement to a dictionary
    static func encode<U, M>(_ measurement: Measurement<U>?, mapper: M.Type) -> [String: Any]? 
    where U: Unit, M: UnitMapper, M.UnitType == U {
        guard let measurement = measurement else { return nil }
        let unitString = M.string(from: measurement.unit)
        return ["value": measurement.value, "unit": unitString]
    }
    
    /// Decode a measurement with a fixed unit (e.g., seconds for duration)
    static func decodeFixedUnit<U: Unit>(_ dict: [String: AnyCodable]?, unit: U) -> Measurement<U>? {
        guard let dict = dict,
              let value = dict["value"]?.doubleValue else {
            return nil
        }
        return Measurement(value: value, unit: unit)
    }
    
    /// Encode a measurement with a fixed unit
    static func encodeFixedUnit<U: Unit>(_ measurement: Measurement<U>?, unitString: String) -> [String: Any]? {
        guard let measurement = measurement else { return nil }
        return ["value": measurement.value, "unit": unitString]
    }
}

