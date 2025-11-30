//
//  CarServiceIntegrationTests.swift
//  CarInspectinatorTests
//
//  Integration tests for the full car service flow
//

import XCTest
@testable import CarInspectinator

final class CarServiceIntegrationTests: XCTestCase {
    
    var container: CIContainer!
    
    override func setUp() {
        super.setUp()
        container = CIContainer()
    }
    
    override func tearDown() {
        container = nil
        super.tearDown()
    }
    
    // MARK: - Dependency Injection Tests
    
    func testContainerCreatesAllServices() {
        // Assert
        XCTAssertNotNil(container.configuration)
        XCTAssertNotNil(container.loggerFactory)
        XCTAssertNotNil(container.networkHandler)
        XCTAssertNotNil(container.carService)
        XCTAssertNotNil(container.modelDownloader)
    }
    
    @MainActor
    func testContainerCreatesHomePageView() {
        // Act
        let view = container.makeHomePageView()
        
        // Assert
        XCTAssertNotNil(view)
    }
    
    // MARK: - Full Stack Integration Tests
    
    @MainActor
    func testCarServiceEndToEndWithMocks() async throws {
        // Arrange
        let mockNetworkHandler = MockNetworkHandler()
        let mockLogger = MockLogger()
        let carService = CarService(networkHandler: mockNetworkHandler, logger: mockLogger)
        
        let testCars = [
            Car(make: "BMW", model: "M3"),
            Car(make: "Audi", model: "RS7")
        ]
        let testData = try JSONEncoder().encode(testCars)
        mockNetworkHandler.mockData = testData
        
        // Act
        let result: [Car] = try await carService.getCars()
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(mockNetworkHandler.requestCallCount, 1)
        XCTAssertTrue(mockLogger.loggedMessages.count > 0)
    }
    
    @MainActor
    func testHomePageViewModelEndToEnd() async throws {
        // Arrange
        let mockCarService = MockCarService()
        let mockLogger = MockLogger()
        let viewModel = HomePageViewModel(carService: mockCarService, logger: mockLogger)
        
        let testCars = [
            Car(make: "BMW", model: "M3"),
            Car(make: "Audi", model: "RS7"),
            Car(make: "Mercedes", model: "G63")
        ]
        mockCarService.mockCars = testCars
        
        // Act
        try await viewModel.getCars()
        
        // Assert
        XCTAssertEqual(viewModel.cars.count, 3)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(mockCarService.getCarsCallCount, 1)
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Successfully loaded", level: .info))
    }
    
    // MARK: - Configuration Integration Tests
    
    func testConfigurationServiceProvidesValidValues() {
        // Arrange
        let config = ConfigurationService.shared
        
        // Assert
        XCTAssertFalse(config.baseURL.isEmpty)
        XCTAssertTrue(config.baseURL.starts(with: "https://"))
        XCTAssertGreaterThan(config.requestTimeout, 0)
        XCTAssertNotNil(config.cacheDirectory)
    }
    
    func testNetworkRoutesUsesConfiguration() {
        // Arrange
        let route = NetworkRoutes.getCars
        
        // Act
        let url = route.url
        
        // Assert
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains(ConfigurationService.shared.baseURL) ?? false)
    }
    
    // MARK: - Error Handling Integration Tests
    
    @MainActor
    func testErrorPropagationThroughLayers() async {
        // Arrange
        let mockNetworkHandler = MockNetworkHandler()
        mockNetworkHandler.shouldThrowError = true
        mockNetworkHandler.mockError = NetworkError.noResponse
        
        let mockLogger = MockLogger()
        let carService = CarService(networkHandler: mockNetworkHandler, logger: mockLogger)
        let viewModel = HomePageViewModel(carService: carService, logger: mockLogger)
        
        // Act & Assert
        do {
            try await viewModel.getCars()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(viewModel.error)
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertTrue(mockLogger.messageCount(for: .error) > 0)
        }
    }
    
    // MARK: - Logging Integration Tests
    
    @MainActor
    func testLoggingThroughoutStack() async throws {
        // Arrange
        let mockNetworkHandler = MockNetworkHandler()
        let mockLogger = MockLogger()
        
        let testCar = Car(make: "BMW", model: "M3")
        let testData = try JSONEncoder().encode(testCar)
        mockNetworkHandler.mockData = testData
        
        let carService = CarService(networkHandler: mockNetworkHandler, logger: mockLogger)
        
        // Act
        _ = try await carService.getCar("test-id")
        
        // Assert
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Fetching car with ID", level: .info))
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Successfully fetched", level: .debug))
    }
    
    // MARK: - Model Downloader Integration Tests
    
    func testModelDownloaderWithConfiguration() {
        // Arrange
        let config = MockConfigurationService()
        let logger = MockLogger()
        
        // Act
        let downloader = ModelDownloader(
            configuration: config,
            fileManager: .default,
            urlSession: .shared,
            logger: logger
        )
        
        // Assert
        XCTAssertNotNil(downloader)
        let cacheURL = downloader.cacheURL(for: "test")
        XCTAssertTrue(cacheURL.absoluteString.contains("TestCache"))
    }
}

