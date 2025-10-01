//
//  Car.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/23/25.
//

import SwiftUI

struct Car: Hashable, Equatable {
    var id: UUID = UUID()
    var make: String
    var model: String
    var description: String?
    var icon: String?
    var horsepower: Int?
    var engineType: String?
    var engineSize: String?
    var year: Int?
    var bodyStyle: BodyStyle?
    var exteriorColor: String?
    var interiorColor: String?
    var interiorPanoramaAssetName: String?
    var volumeID: String?
    var otherSpecs: [String: String] = [:]
    
    init(
        make: String,
        model: String,
        icon: String? = nil,
        horsepower: Int? = nil,
        engineType: String? = nil,
        engineSize: String? = nil,
        year: Int? = nil,
        bodyStyle: BodyStyle? = nil,
        exteriorColor: String? = nil,
        interiorColor: String? = nil,
        interiorPanoramaAssetName: String? = nil,
        volumeID: String? = nil,
        otherSpecs: [String: String] = [:]
    ) {
        self.make = make
        self.model = model
        self.icon = icon
        self.horsepower = horsepower
        self.engineType = engineType
        self.engineSize = engineSize
        self.year = year
        self.bodyStyle = bodyStyle
        self.exteriorColor = exteriorColor
        self.interiorColor = interiorColor
        self.interiorPanoramaAssetName = interiorPanoramaAssetName
        self.volumeID = volumeID
        self.otherSpecs = otherSpecs
    }
}


enum BodyStyle: String {
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


var carsArray = [
    Car(
        make: "Volkswagen",
        model: "Golf GTI",
        icon: "vw_gti",
        horsepower: 330,
        engineType: "Diesel",
        engineSize: "1.8L",
        year: 2020,
        bodyStyle: .hatchback,
        volumeID: "vw_golf_5_gti",
        otherSpecs: [
            "torque": "258 lb-ft @ 1,500 rpm",
            "transmission": "6-speed manual or 7-speed DSG",
            "drivetrain": "Front-wheel drive",
            "differential": "Front limited-slip (VAQ)",
            "epaMPG": "24 city / 32 highway",
            "fuelTank": "13.2 gal",
            "wheelbase": "103.6 in",
            "length": "168.0 in",
            "cargoRearSeatsUp": "22.8 cu ft",
            "curbWeight": "3,128 lb"
        ]
    ),
    Car(make: "BMW", model: "M3", icon: "bmw_m3", volumeID: "BMW_M4_f82"),
    Car(make: "Audi", model: "RS7", icon: "audi_rs7"),
    Car(make: "Mercedes", model: "G63", icon: "mercedes_g63"),
    Car(make: "Toyota", model: "Supra", icon: "toyota_supra")
]
