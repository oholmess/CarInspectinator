//
//  NetworkRoutes.swift
//  CarInspectinator
//
//  Refactored to use ConfigurationService for base URL
//

import Foundation

enum NetworkRoutes {
    case getCar(carId: String)
    case getCars
    
    var url: URL? {
        let baseUrl = ConfigurationService.shared.baseURL
        let path: String
        
        switch self {
        case .getCar(let carId):
            path = "\(baseUrl)/v1/cars/\(carId)"
        case .getCars:
            path = "\(baseUrl)/v1/cars"
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
