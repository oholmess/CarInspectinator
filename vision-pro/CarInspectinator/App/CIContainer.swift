//
//  CIContainer.swift
//  CarInspectinator
//
//  Refactored to follow Dependency Injection and SOLID principles
//

import SwiftUI
import Foundation

/// Dependency injection container following SOLID principles
final class CIContainer: EnvironmentKey {
    static var defaultValue: CIContainer { CIContainer() }
    
    // MARK: - Core Services
    
    lazy var configuration: ConfigurationServiceProtocol = {
        ConfigurationService.shared
    }()
    
    lazy var loggerFactory: LoggerFactory = {
        LoggerFactory.shared
    }()
    
    // MARK: - Network Layer
    
    lazy var networkHandler: NetworkHandlerProtocol = {
        NetworkHandler(
            logger: loggerFactory.logger(for: "Network"),
            urlSession: .shared
        )
    }()
    
    // MARK: - Services
    
    lazy var carService: any CarServiceType = {
        CarService(
            networkHandler: networkHandler,
            logger: loggerFactory.logger(for: "CarService")
        )
    }()
    
    lazy var modelDownloader: ModelDownloaderProtocol = {
        ModelDownloader(
            configuration: configuration,
            fileManager: .default,
            urlSession: .shared,
            logger: loggerFactory.logger(for: "ModelDownloader")
        )
    }()
    
    // MARK: - View Factories
    
    func makeHomePageView() -> HopePageView<HomePageViewModel> {
        let viewModel = HomePageViewModel(
            carService: carService,
            logger: loggerFactory.logger(for: "HomePageViewModel")
        )
        return HopePageView(vm: viewModel)
    }
}


extension EnvironmentValues {
    var injected: CIContainer {
        get { self[CIContainer.self] }
        set { self[CIContainer.self] = newValue }
    }
}

extension View {
    func addContainer(_ container: CIContainer) -> some View {
        environment(\.injected, container)
    }
}
