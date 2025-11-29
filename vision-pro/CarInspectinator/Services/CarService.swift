//
//  CarService.swift
//  CarInspectinator
//
//  Refactored to follow DRY and SOLID principles
//

import Foundation
import Combine

// MARK: - Protocol (Interface Segregation & Dependency Inversion)

protocol CarServiceType: ObservableObject {
    func getCar(_ carId: String) async throws -> Car
    func getCars() async throws -> [Car]
}

// MARK: - Implementation

class CarService: CarServiceType {
    private let networkHandler: NetworkHandlerProtocol
    private let logger: LoggerProtocol
    
    init(
        networkHandler: NetworkHandlerProtocol = NetworkHandler(),
        logger: LoggerProtocol = LoggerFactory.shared.logger(for: "CarService")
    ) {
        self.networkHandler = networkHandler
        self.logger = logger
    }
    
    // MARK: - Public Methods
    
    func getCar(_ carId: String) async throws -> Car {
        logger.info("Fetching car with ID: \(carId)", file: #file, function: #function, line: #line)
        return try await performRequest(route: .getCar(carId: carId))
    }
    
    func getCars() async throws -> [Car] {
        logger.info("Fetching all cars", file: #file, function: #function, line: #line)
        return try await performRequest(route: .getCars)
    }
    
    // MARK: - Private Helpers (DRY Principle)
    
    private func performRequest<T: Decodable>(route: NetworkRoutes) async throws -> T {
        guard let url = route.url else {
            logger.error("Failed to create URL for route: \(route)", file: #file, function: #function, line: #line)
            throw ConfigurationError.nilObject
        }
        
        do {
            let result: T = try await networkHandler.request(
                url,
                jsonDictionary: nil,
                responseType: T.self,
                httpMethod: route.method.rawValue,
                contentType: ContentType.json.rawValue,
                accessToken: nil
            )
            
            logger.debug("Successfully fetched data for route: \(route)", file: #file, function: #function, line: #line)
            return result
        } catch {
            logger.error("Failed to fetch data: \(error.localizedDescription)", file: #file, function: #function, line: #line)
            throw error
        }
    }
}
