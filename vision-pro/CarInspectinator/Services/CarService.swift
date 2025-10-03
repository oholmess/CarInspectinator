//
//  CarService.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 10/3/25.
//

import Foundation
import Combine

protocol CarServiceType: ObservableObject {
    func getCar(_ carId: String) async -> Car?
    func getCars() async -> [Car]?
}

class CarService: CarServiceType {
    private let networkHandler: NetworkHandler
    
    init(networkHandler: NetworkHandler = NetworkHandler()) {
        self.networkHandler = networkHandler
    }
}

extension CarService {
    func getCar(_ carId: String) async -> Car? {
        do {
            let route = NetworkRoutes.getCar(carId: carId)
            let method = route.method
            guard let url = route.url else {
                print("Failed to create/find URL")
                throw ConfigurationError.nilObject
            }
            
            let responseData = try await networkHandler.request(url,
                                                                responseType: Car.self,
                                                                httpMethod: method.rawValue)
            
            print("Response data: \(responseData)")
            
            return responseData
        } catch {
            print("Error fetching current car with ID: \(carId) with error: ", error)
            return nil
        }
    }
    
    func getCars() async -> [Car]? {
        do {
            let route = NetworkRoutes.getCars
            let method = route.method
            guard let url = route.url else {
                print("Failed to create/find URL")
                throw ConfigurationError.nilObject
            }
            
            let responseData = try await networkHandler.request(url,
                                                                responseType: [Car].self,
                                                                httpMethod: method.rawValue)
            
            print("Response data: \(responseData)")
            
            return responseData
        } catch {
            print("Error fetching current cars with error: ", error)
            return nil
        }
    }
}
