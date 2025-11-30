//
//  MocksTests.swift
//  CarInspectinatorTests
//
//  Tests to verify mock implementations work correctly
//  This also increases coverage of the mock classes
//

import XCTest
@testable import CarInspectinator

// MARK: - MockNetworkHandler Tests

final class MockNetworkHandlerTests: XCTestCase {
    
    var sut: MockNetworkHandler!
    
    override func setUp() {
        super.setUp()
        sut = MockNetworkHandler()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testReset_ClearsAllState() {
        // Given
        sut.mockData = "test".data(using: .utf8)
        sut.mockError = NetworkError.noResponse
        sut.shouldThrowError = true
        sut.requestCallCount = 5
        
        // When
        sut.reset()
        
        // Then
        XCTAssertNil(sut.mockData)
        XCTAssertNil(sut.mockError)
        XCTAssertFalse(sut.shouldThrowError)
        XCTAssertEqual(sut.requestCallCount, 0)
        XCTAssertNil(sut.lastRequestURL)
        XCTAssertNil(sut.lastHttpMethod)
    }
    
    func testRequest_IncrementsCallCount() async throws {
        // Given
        sut.mockData = "test".data(using: .utf8)
        let url = URL(string: "https://example.com")!
        
        // When
        _ = try await sut.request(url)
        
        // Then
        XCTAssertEqual(sut.requestCallCount, 1)
    }
    
    func testRequest_SavesLastURL() async throws {
        // Given
        sut.mockData = "test".data(using: .utf8)
        let url = URL(string: "https://example.com/api")!
        
        // When
        _ = try await sut.request(url)
        
        // Then
        XCTAssertEqual(sut.lastRequestURL, url)
    }
    
    func testRequest_ThrowsWhenShouldThrowError() async {
        // Given
        sut.shouldThrowError = true
        sut.mockError = NetworkError.noResponse
        let url = URL(string: "https://example.com")!
        
        // When/Then
        do {
            _ = try await sut.request(url)
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testRequest_ReturnsNoResponseWhenNoMockData() async {
        // Given
        let url = URL(string: "https://example.com")!
        
        // When/Then
        do {
            _ = try await sut.request(url)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .noResponse)
        }
    }
}

// MARK: - MockLogger Tests

final class MockLoggerTests: XCTestCase {
    
    var sut: MockLogger!
    
    override func setUp() {
        super.setUp()
        sut = MockLogger()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testLog_AddsMessage() {
        // When
        sut.log("Test message", level: .info, file: #file, function: #function, line: #line)
        
        // Then
        XCTAssertEqual(sut.loggedMessages.count, 1)
    }
    
    func testDebug_AddsDebugMessage() {
        // When
        sut.debug("Debug message", file: #file, function: #function, line: #line)
        
        // Then
        XCTAssertTrue(sut.hasLoggedMessage(containing: "Debug", level: .debug))
    }
    
    func testInfo_AddsInfoMessage() {
        // When
        sut.info("Info message", file: #file, function: #function, line: #line)
        
        // Then
        XCTAssertTrue(sut.hasLoggedMessage(containing: "Info", level: .info))
    }
    
    func testWarning_AddsWarningMessage() {
        // When
        sut.warning("Warning message", file: #file, function: #function, line: #line)
        
        // Then
        XCTAssertTrue(sut.hasLoggedMessage(containing: "Warning", level: .warning))
    }
    
    func testError_AddsErrorMessage() {
        // When
        sut.error("Error message", file: #file, function: #function, line: #line)
        
        // Then
        XCTAssertTrue(sut.hasLoggedMessage(containing: "Error", level: .error))
    }
    
    func testReset_ClearsAllMessages() {
        // Given
        sut.info("Message 1", file: #file, function: #function, line: #line)
        sut.error("Message 2", file: #file, function: #function, line: #line)
        
        // When
        sut.reset()
        
        // Then
        XCTAssertTrue(sut.loggedMessages.isEmpty)
    }
    
    func testHasLoggedMessage_ReturnsTrueForMatch() {
        // Given
        sut.info("Test message content", file: #file, function: #function, line: #line)
        
        // When/Then
        XCTAssertTrue(sut.hasLoggedMessage(containing: "content"))
    }
    
    func testHasLoggedMessage_ReturnsFalseForNoMatch() {
        // Given
        sut.info("Test message", file: #file, function: #function, line: #line)
        
        // When/Then
        XCTAssertFalse(sut.hasLoggedMessage(containing: "nonexistent"))
    }
    
    func testMessageCount_ReturnsCorrectCount() {
        // Given
        sut.info("Info 1", file: #file, function: #function, line: #line)
        sut.info("Info 2", file: #file, function: #function, line: #line)
        sut.error("Error 1", file: #file, function: #function, line: #line)
        
        // When
        let infoCount = sut.messageCount(for: .info)
        let errorCount = sut.messageCount(for: .error)
        
        // Then
        XCTAssertEqual(infoCount, 2)
        XCTAssertEqual(errorCount, 1)
    }
}

// MARK: - MockCarService Tests

@MainActor
final class MockCarServiceTests: XCTestCase {
    
    var sut: MockCarService!
    
    override func setUp() {
        super.setUp()
        sut = MockCarService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testGetCars_ReturnsEmptyByDefault() async throws {
        // When
        let cars = try await sut.getCars()
        
        // Then
        XCTAssertTrue(cars.isEmpty)
    }
    
    func testGetCars_ReturnsMockCars() async throws {
        // Given
        sut.mockCars = [createMockCar(), createMockCar()]
        
        // When
        let cars = try await sut.getCars()
        
        // Then
        XCTAssertEqual(cars.count, 2)
    }
    
    func testGetCars_IncrementsCallCount() async throws {
        // When
        _ = try await sut.getCars()
        
        // Then
        XCTAssertEqual(sut.getCarsCallCount, 1)
    }
    
    func testGetCars_ThrowsWhenShouldThrowError() async {
        // Given
        sut.shouldThrowError = true
        sut.errorToThrow = NetworkError.noResponse
        
        // When/Then
        do {
            _ = try await sut.getCars()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testGetCar_ReturnsMockCar() async throws {
        // Given
        let mockCar = createMockCar()
        sut.mockCar = mockCar
        
        // When
        let car = try await sut.getCar("test-123")
        
        // Then
        XCTAssertEqual(car.id, mockCar.id)
    }
    
    func testGetCar_TracksLastCarIdRequested() async throws {
        // Given
        sut.mockCar = createMockCar()
        
        // When
        _ = try await sut.getCar("car-456")
        
        // Then
        XCTAssertEqual(sut.lastCarIdRequested, "car-456")
    }
    
    func testGetCar_IncrementsCallCount() async throws {
        // Given
        sut.mockCar = createMockCar()
        
        // When
        _ = try await sut.getCar("test")
        
        // Then
        XCTAssertEqual(sut.getCarCallCount, 1)
    }
    
    func testReset_ClearsAllState() async throws {
        // Given
        sut.mockCars = [createMockCar()]
        sut.mockCar = createMockCar()
        sut.shouldThrowError = true
        _ = try? await sut.getCars()
        
        // When
        sut.reset()
        
        // Then
        XCTAssertTrue(sut.mockCars.isEmpty)
        XCTAssertNil(sut.mockCar)
        XCTAssertFalse(sut.shouldThrowError)
        XCTAssertEqual(sut.getCarsCallCount, 0)
        XCTAssertEqual(sut.getCarCallCount, 0)
        XCTAssertNil(sut.lastCarIdRequested)
    }
    
    // MARK: - Helpers
    
    private func createMockCar() -> Car {
        return Car(
            id: UUID(),
            make: "TestMake",
            model: "TestModel",
            blurb: "Test",
            iconAssetName: "icon",
            year: 2024,
            bodyStyle: .sedan,
            exteriorColor: "Blue",
            interiorColor: "Black",
            interiorPanoramaAssetName: nil,
            volumeId: nil,
            modelUrl: nil,
            engine: nil,
            performance: nil,
            dimensions: nil,
            drivetrain: nil,
            otherSpecs: [:]
        )
    }
}

// MARK: - MockModelDownloader Tests

final class MockModelDownloaderTests: XCTestCase {
    
    var sut: MockModelDownloader!
    
    override func setUp() {
        super.setUp()
        sut = MockModelDownloader()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCacheURL_ReturnsURL() {
        // When
        let url = sut.cacheURL(for: "test-volume")
        
        // Then
        XCTAssertNotNil(url)
    }
    
    func testIsCached_ReturnsFalseByDefault() {
        // When
        let cached = sut.isCached(volumeId: "test")
        
        // Then
        XCTAssertFalse(cached)
    }
    
    func testIsCached_ReturnsTrueWhenInMockCachedFiles() {
        // Given
        sut.mockCachedFiles.insert("cached-volume")
        
        // When
        let cached = sut.isCached(volumeId: "cached-volume")
        
        // Then
        XCTAssertTrue(cached)
    }
    
    func testDownloadModel_IncrementsCallCount() async throws {
        // Given
        let url = URL(string: "https://example.com/model.usdz")!
        
        // When
        _ = try await sut.downloadModel(from: url, volumeId: "test")
        
        // Then
        XCTAssertEqual(sut.downloadCallCount, 1)
    }
    
    func testDownloadModel_ThrowsWhenShouldThrowError() async {
        // Given
        sut.shouldThrowError = true
        sut.errorToThrow = NetworkError.noResponse
        let url = URL(string: "https://example.com/model.usdz")!
        
        // When/Then
        do {
            _ = try await sut.downloadModel(from: url, volumeId: "test")
            XCTFail("Expected error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testClearCache_DoesNotThrow() {
        // When/Then - Should not throw
        sut.clearCache(for: "test")
    }
    
    func testClearAllCache_DoesNotThrow() {
        // When/Then - Should not throw
        sut.clearAllCache()
    }
    
    func testGetCacheSize_ReturnsZeroByDefault() async {
        // When
        let size = await sut.getCacheSize()
        
        // Then
        XCTAssertEqual(size, 0)
    }
    
    func testReset_ClearsAllState() {
        // Given
        sut.mockCachedFiles.insert("file")
        sut.shouldThrowError = true
        sut.downloadCallCount = 5
        
        // When
        sut.reset()
        
        // Then
        XCTAssertTrue(sut.mockCachedFiles.isEmpty)
        XCTAssertFalse(sut.shouldThrowError)
        XCTAssertEqual(sut.downloadCallCount, 0)
    }
}

// MARK: - MockConfigurationService Tests

final class MockConfigurationServiceTests: XCTestCase {
    
    var sut: MockConfigurationService!
    
    override func setUp() {
        super.setUp()
        sut = MockConfigurationService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testBaseURL_HasDefaultValue() {
        // When
        let baseURL = sut.baseURL
        
        // Then
        XCTAssertFalse(baseURL.isEmpty)
    }
    
    func testRequestTimeout_HasDefaultValue() {
        // When
        let timeout = sut.requestTimeout
        
        // Then
        XCTAssertGreaterThan(timeout, 0)
    }
    
    func testCacheDirectory_IsNotNil() {
        // When
        let cacheDir = sut.cacheDirectory
        
        // Then
        XCTAssertNotNil(cacheDir)
    }
}
