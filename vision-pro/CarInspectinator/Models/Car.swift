//
//  Car.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/23/25.
//

import SwiftUI
import Foundation

// MARK: - Helpers for decoding API measurements

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        }
    }
    
    var stringValue: String? { value as? String }
    var intValue: Int? { value as? Int }
    var doubleValue: Double? {
        if let doubleVal = value as? Double { return doubleVal }
        if let intVal = value as? Int { return Double(intVal) }
        return nil
    }
}

struct AnyCodableDict: Codable {
    let dict: [String: Any]
    
    init(_ dict: [String: Any]) {
        self.dict = dict
    }
    
    init(from decoder: Decoder) throws {
        self.dict = [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        for (key, value) in dict {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let string = value as? String {
                try container.encode(string, forKey: codingKey)
            } else if let double = value as? Double {
                try container.encode(double, forKey: codingKey)
            } else if let int = value as? Int {
                try container.encode(int, forKey: codingKey)
            }
        }
    }
}

struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

// MARK: - Model

struct Car: Identifiable, Hashable, Equatable, Codable, Sendable {
    // Required
    let id: UUID
    let make: String
    let model: String

    // Optional / nice-to-have
    let blurb: String?
    let iconAssetName: String?
    let year: Int?
    let bodyStyle: BodyStyle?
    let exteriorColor: String?
    let interiorColor: String?
    let interiorPanoramaAssetName: String?
    let volumeId: String?
    let modelUrl: String?  // Signed GCS URL for 3D model

    // Typed substructures
    let engine: Engine?
    let performance: Performance?
    let dimensions: Dimensions?
    let drivetrain: Drivetrain?

    // Escape hatch for anything not yet modeled
    let otherSpecs: [String: String]

    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        blurb: String? = nil,
        iconAssetName: String? = nil,
        year: Int? = nil,
        bodyStyle: BodyStyle? = nil,
        exteriorColor: String? = nil,
        interiorColor: String? = nil,
        interiorPanoramaAssetName: String? = nil,
        volumeId: String? = nil,
        modelUrl: String? = nil,
        engine: Engine? = nil,
        performance: Performance? = nil,
        dimensions: Dimensions? = nil,
        drivetrain: Drivetrain? = nil,
        otherSpecs: [String: String] = [:]
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.blurb = blurb
        self.iconAssetName = iconAssetName
        self.year = year
        self.bodyStyle = bodyStyle
        self.exteriorColor = exteriorColor
        self.interiorColor = interiorColor
        self.interiorPanoramaAssetName = interiorPanoramaAssetName
        self.volumeId = volumeId
        self.modelUrl = modelUrl
        self.engine = engine
        self.performance = performance
        self.dimensions = dimensions
        self.drivetrain = drivetrain
        self.otherSpecs = otherSpecs
    }

    // Handy UI helpers
    var displayName: String {
        if let year { return "\(year) \(make) \(model)" }
        return "\(make) \(model)"
    }

    var heroIcon: Image? {
        iconAssetName.map { Image($0) }
    }
}

// MARK: - Enums & nested types

enum BodyStyle: String, Codable, Sendable {
    case coupe = "Coupe"
    case hatchback = "Hatchback"
    case sedan = "Sedan"
    case suv = "SUV"
    case wagon = "Wagon"
    case truck = "Truck"
    case minivan = "Minivan"
    case other = "Other"
    case notSpecified = "Not Specified"
}

enum FuelType: String, Codable, Sendable {
    case gasoline, diesel, hybrid, plugInHybrid, electric, hydrogen, other
}

enum Induction: String, Codable, Sendable {
    case naturallyAspirated, turbocharged, supercharged, twinCharged, other
}

enum Transmission: String, Codable, Sendable {
    case manual, automatic, dct, cvt, other
}

enum DriveLayout: String, Codable, Sendable {
    case fwd, rwd, awd, fourwd, other
}

struct Engine: Hashable, Equatable, Sendable {
    /// e.g. 2.0 liters
    var displacement: Measurement<UnitVolume>? // use .liters
    var cylinders: Int?
    var configuration: String? // i4, V6, B6, etc.
    var fuel: FuelType?
    var induction: Induction?
    var code: String? // e.g., "EA888"
}

extension Engine: Codable {
    enum CodingKeys: String, CodingKey {
        case displacement, cylinders, configuration, fuel, induction, code
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let displacementDict = try container.decodeIfPresent([String: AnyCodable].self, forKey: .displacement)
        displacement = MeasurementCodec.decode(displacementDict, mapper: VolumeUnitMapper.self)
        
        cylinders = try container.decodeIfPresent(Int.self, forKey: .cylinders)
        configuration = try container.decodeIfPresent(String.self, forKey: .configuration)
        fuel = try container.decodeIfPresent(FuelType.self, forKey: .fuel)
        induction = try container.decodeIfPresent(Induction.self, forKey: .induction)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let dict = MeasurementCodec.encode(displacement, mapper: VolumeUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .displacement)
        }
        
        try container.encodeIfPresent(cylinders, forKey: .cylinders)
        try container.encodeIfPresent(configuration, forKey: .configuration)
        try container.encodeIfPresent(fuel, forKey: .fuel)
        try container.encodeIfPresent(induction, forKey: .induction)
        try container.encodeIfPresent(code, forKey: .code)
    }
}

/// Custom unit type for torque since Foundation does not provide one.
final class UnitTorque: Dimension, @unchecked Sendable {
    static let newtonMeters = UnitTorque(symbol: "N·m", converter: UnitConverterLinear(coefficient: 1.0))
    static let poundForceFeet = UnitTorque(symbol: "lbf·ft", converter: UnitConverterLinear(coefficient: 1.3558179483314004))

    override class func baseUnit() -> Self {
        // swiftlint:disable:next force_cast
        return newtonMeters as! Self
    }
}

struct Performance: Hashable, Equatable, Sendable {
    /// Use .horsepower and .newtonMeters or .poundForceFeet
    var horsepower: Measurement<UnitPower>?
    var torque: Measurement<UnitTorque>?
    var zeroToSixty: Measurement<UnitDuration>? // seconds
    var topSpeed: Measurement<UnitSpeed>? // km/h or mph
    var epaCity: Measurement<UnitFuelEfficiency>? // mpg/100km etc. pick one consistently
    var epaHighway: Measurement<UnitFuelEfficiency>?
}

extension Performance: Codable {
    enum CodingKeys: String, CodingKey {
        case horsepower, torque, zeroToSixty, topSpeed, epaCity, epaHighway
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        horsepower = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .horsepower),
            mapper: PowerUnitMapper.self
        )
        
        torque = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .torque),
            mapper: TorqueUnitMapper.self
        )
        
        zeroToSixty = MeasurementCodec.decodeFixedUnit(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .zeroToSixty),
            unit: .seconds
        )
        
        topSpeed = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .topSpeed),
            mapper: SpeedUnitMapper.self
        )
        
        epaCity = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .epaCity),
            mapper: FuelEfficiencyUnitMapper.self
        )
        
        epaHighway = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .epaHighway),
            mapper: FuelEfficiencyUnitMapper.self
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let dict = MeasurementCodec.encode(horsepower, mapper: PowerUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .horsepower)
        }
        
        if let dict = MeasurementCodec.encode(torque, mapper: TorqueUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .torque)
        }
        
        if let dict = MeasurementCodec.encodeFixedUnit(zeroToSixty, unitString: "seconds") {
            try container.encode(AnyCodableDict(dict), forKey: .zeroToSixty)
        }
        
        if let dict = MeasurementCodec.encode(topSpeed, mapper: SpeedUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .topSpeed)
        }
        
        if let dict = MeasurementCodec.encode(epaCity, mapper: FuelEfficiencyUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .epaCity)
        }
        
        if let dict = MeasurementCodec.encode(epaHighway, mapper: FuelEfficiencyUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .epaHighway)
        }
    }
}

struct Dimensions: Hashable, Equatable, Sendable {
    var wheelbase: Measurement<UnitLength>?
    var length: Measurement<UnitLength>?
    var width: Measurement<UnitLength>?
    var height: Measurement<UnitLength>?
    var curbWeight: Measurement<UnitMass>?
    var cargoRearSeatsUp: Measurement<UnitVolume>?
    var fuelTank: Measurement<UnitVolume>?
}

extension Dimensions: Codable {
    enum CodingKeys: String, CodingKey {
        case wheelbase, length, width, height, curbWeight, cargoRearSeatsUp, fuelTank
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        wheelbase = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .wheelbase),
            mapper: LengthUnitMapper.self
        )
        
        length = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .length),
            mapper: LengthUnitMapper.self
        )
        
        width = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .width),
            mapper: LengthUnitMapper.self
        )
        
        height = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .height),
            mapper: LengthUnitMapper.self
        )
        
        curbWeight = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .curbWeight),
            mapper: MassUnitMapper.self
        )
        
        cargoRearSeatsUp = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .cargoRearSeatsUp),
            mapper: VolumeUnitMapper.self
        )
        
        fuelTank = MeasurementCodec.decode(
            try container.decodeIfPresent([String: AnyCodable].self, forKey: .fuelTank),
            mapper: VolumeUnitMapper.self
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let dict = MeasurementCodec.encode(wheelbase, mapper: LengthUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .wheelbase)
        }
        
        if let dict = MeasurementCodec.encode(length, mapper: LengthUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .length)
        }
        
        if let dict = MeasurementCodec.encode(width, mapper: LengthUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .width)
        }
        
        if let dict = MeasurementCodec.encode(height, mapper: LengthUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .height)
        }
        
        if let dict = MeasurementCodec.encode(curbWeight, mapper: MassUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .curbWeight)
        }
        
        if let dict = MeasurementCodec.encode(cargoRearSeatsUp, mapper: VolumeUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .cargoRearSeatsUp)
        }
        
        if let dict = MeasurementCodec.encode(fuelTank, mapper: VolumeUnitMapper.self) {
            try container.encode(AnyCodableDict(dict), forKey: .fuelTank)
        }
    }
}

struct Drivetrain: Hashable, Equatable, Codable, Sendable {
    var layout: DriveLayout?
    var differential: String? // e.g., "Front limited-slip (VAQ)"
    var transmission: Transmission?
    var gears: Int?
}

// MARK: - Samples / Fixtures

let cars: [Car] = [
    Car(
        make: "Volkswagen",
        model: "Golf GTI",
        iconAssetName: "vw_gti",
        year: 2020,
        bodyStyle: .hatchback,
        volumeId: "vw_golf_5_gti",
        engine: Engine(
            displacement: Measurement(value: 1.8, unit: UnitVolume.liters), // adjust if you want 2.0L
            cylinders: 4,
            configuration: "I4",
            fuel: .diesel, // change to .gasoline if this was a placeholder
            induction: .turbocharged,
            code: nil
        ),
        performance: Performance(
            horsepower: Measurement(value: 330, unit: UnitPower.horsepower),
            torque: Measurement(value: 258, unit: UnitTorque.poundForceFeet),
            zeroToSixty: nil,
            topSpeed: nil,
            epaCity: nil,
            epaHighway: nil
        ),
        dimensions: Dimensions(
            wheelbase: Measurement(value: 103.6, unit: UnitLength.inches),
            length: Measurement(value: 168.0, unit: UnitLength.inches),
            width: nil,
            height: nil,
            curbWeight: Measurement(value: 3128, unit: UnitMass.pounds),
            cargoRearSeatsUp: Measurement(value: 22.8, unit: UnitVolume.gallons) // or use .liters if you prefer
        ),
        drivetrain: Drivetrain(
            layout: .fwd,
            differential: "Front limited-slip (VAQ)",
            transmission: .manual,
            gears: 6
        ),
        otherSpecs: [
            "epaMPG": "24 city / 32 highway",
            "altTransmission": "7-speed DSG"
        ]
    ),
    Car(make: "BMW", model: "M3", iconAssetName: "bmw_m3", volumeId: "BMW_M4_f82"),
    Car(make: "Audi", model: "RS7", iconAssetName: "audi_rs7", volumeId: "2020_Audi_RS7_Sportback"),
    Car(make: "Mercedes", model: "G63", iconAssetName: "mercedes_g63", volumeId: "2020_Mercedes-Benz_G-Class_AMG_G63"),
    Car(make: "Toyota", model: "Supra", iconAssetName: "toyota_supra", volumeId: "Toyota_Supra")
]

