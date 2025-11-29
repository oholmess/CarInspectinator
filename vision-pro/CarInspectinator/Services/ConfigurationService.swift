//
//  ConfigurationService.swift
//  CarInspectinator
//
//  Configuration service following Single Responsibility Principle
//

import Foundation

/// Protocol for configuration management (Dependency Inversion Principle)
protocol ConfigurationServiceProtocol {
    var baseURL: String { get }
    var requestTimeout: TimeInterval { get }
    var cacheDirectory: URL { get }
}

/// Default implementation of configuration service
final class ConfigurationService: ConfigurationServiceProtocol {
    static let shared = ConfigurationService()
    
    var baseURL: String {
        // In production, this could come from Info.plist or environment variables
        "https://car-service-469466026461.europe-west1.run.app"
    }
    
    var requestTimeout: TimeInterval {
        30.0
    }
    
    var cacheDirectory: URL {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDir.appendingPathComponent("CarModels", isDirectory: true)
    }
    
    private init() {}
}

