//
//  MockCarService.swift
//  CarInspectinatorTests
//
//  Mock implementation of CarServiceType for testing
//

import Foundation
import Combine
@testable import CarInspectinator

@MainActor
final class MockCarService: CarServiceType, ObservableObject {
    // Configure mock behavior
    var mockCars: [Car] = []
    var mockCar: Car?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.noResponse
    
    // Track calls
    var getCarsCallCount = 0
    var getCarCallCount = 0
    var lastCarIdRequested: String?
    
    func getCars() async throws -> [Car] {
        getCarsCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockCars
    }
    
    func getCar(_ carId: String) async throws -> Car {
        getCarCallCount += 1
        lastCarIdRequested = carId
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let car = mockCar else {
            throw NetworkError.dataError("Car not found")
        }
        
        return car
    }
    
    // Helper methods
    func reset() {
        mockCars = []
        mockCar = nil
        shouldThrowError = false
        getCarsCallCount = 0
        getCarCallCount = 0
        lastCarIdRequested = nil
    }
}

