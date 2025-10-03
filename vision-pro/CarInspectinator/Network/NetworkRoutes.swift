//
//  NetworkRoutes.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 10/3/25.
//


import Foundation

enum NetworkRoutes {
    private static let baseUrl = "http://localhost:8080"
    
    case getCar(carId: String)
    case getCars
    
    var url: URL? {
        var path: String
        switch self {
        case .getCar(let carId):
            path = NetworkRoutes.baseUrl + "/v1/cars/\(carId)"
        case .getCars:
            path = NetworkRoutes.baseUrl + "/v1/cars"
        }
        
        return URL(string: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .getCar, .getCars:
            return .get
        }
    }
    
}
