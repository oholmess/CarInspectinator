//
//  HomePageViewModel.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 10/3/25.
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
    
    private let networkHandler: NetworkHandler
    
    init(networkHandler: NetworkHandler) {
        self.networkHandler = networkHandler
    }
    
    func getCars() async throws {
        await MainActor.run { isLoading = true }
        do {
            let route = NetworkRoutes.getCars
            let method = route.method
            guard let url = route.url else {
                print("Failed to create/find URL")
                throw ConfigurationError.nilObject
            }
            
            let cars = try await networkHandler.request(
                url,
                responseType: [Car].self,
                httpMethod: method.rawValue
            )
            
            print("DEBUG: cars: \(cars)")
            
            await MainActor.run {
                self.cars = cars
                isLoading = false
            }
        } catch {
            print("Failed to get cars: \(error)")
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
    
}
