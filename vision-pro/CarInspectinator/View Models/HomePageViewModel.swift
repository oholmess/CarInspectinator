//
//  HomePageViewModel.swift
//  CarInspectinator
//
//  Refactored to use CarService and follow SOLID principles
//

import Foundation
import Combine

protocol HomePageViewModelType: ObservableObject {
    var cars: [Car] { get set }
    var isLoading: Bool { get }
    var error: Error? { get set }
    
    func getCars() async throws
}

class HomePageViewModel: HomePageViewModelType {
    @Published var cars: [Car] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let carService: any CarServiceType
    private let logger: LoggerProtocol
    
    init(
        carService: any CarServiceType,
        logger: LoggerProtocol = LoggerFactory.shared.logger(for: "HomePageViewModel")
    ) {
        self.carService = carService
        self.logger = logger
    }
    
    func getCars() async throws {
        setLoading(true)
        
        do {
            let cars = try await carService.getCars()
            logger.info("Successfully loaded \(cars.count) cars", file: #file, function: #function, line: #line)
            
            await MainActor.run {
                self.cars = cars
                self.error = nil  // Clear any previous errors on success
                self.isLoading = false
            }
        } catch {
            logger.error("Failed to get cars: \(error.localizedDescription)", file: #file, function: #function, line: #line)
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Private Helpers
    
    @MainActor
    private func setLoading(_ loading: Bool) {
        isLoading = loading
    }
}
