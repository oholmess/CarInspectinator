//
//  MockConfigurationService.swift
//  CarInspectinatorTests
//
//  Mock implementation of ConfigurationServiceProtocol for testing
//

import Foundation
@testable import CarInspectinator

final class MockConfigurationService: ConfigurationServiceProtocol {
    var baseURL: String = "https://test-api.example.com"
    var requestTimeout: TimeInterval = 30.0
    var cacheDirectory: URL = {
        FileManager.default.temporaryDirectory.appendingPathComponent("TestCache")
    }()
}

