//
//  ConfigurationServiceTests.swift
//  CarInspectinatorTests
//
//  Unit tests for ConfigurationService
//

import XCTest
@testable import CarInspectinator

final class ConfigurationServiceTests: XCTestCase {
    
    var sut: ConfigurationService!
    
    override func setUp() {
        super.setUp()
        sut = ConfigurationService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - baseURL Tests
    
    func testBaseURL_ReturnsValidURL() {
        // When
        let baseURL = sut.baseURL
        
        // Then
        XCTAssertFalse(baseURL.isEmpty)
        XCTAssertTrue(baseURL.hasPrefix("https://"))
    }
    
    func testBaseURL_ContainsExpectedDomain() {
        // When
        let baseURL = sut.baseURL
        
        // Then
        XCTAssertTrue(baseURL.contains("car-service"))
    }
    
    // MARK: - requestTimeout Tests
    
    func testRequestTimeout_ReturnsPositiveValue() {
        // When
        let timeout = sut.requestTimeout
        
        // Then
        XCTAssertGreaterThan(timeout, 0)
    }
    
    func testRequestTimeout_ReturnsReasonableValue() {
        // When
        let timeout = sut.requestTimeout
        
        // Then
        XCTAssertEqual(timeout, 30.0)
    }
    
    // MARK: - cacheDirectory Tests
    
    func testCacheDirectory_ReturnsValidURL() {
        // When
        let cacheDir = sut.cacheDirectory
        
        // Then
        XCTAssertFalse(cacheDir.path.isEmpty)
    }
    
    func testCacheDirectory_ContainsCarModels() {
        // When
        let cacheDir = sut.cacheDirectory
        
        // Then
        XCTAssertTrue(cacheDir.path.contains("CarModels"))
    }
    
    func testCacheDirectory_IsInCachesDirectory() {
        // When
        let cacheDir = sut.cacheDirectory
        
        // Then
        XCTAssertTrue(cacheDir.path.contains("Caches"))
    }
    
    // MARK: - Singleton Tests
    
    func testShared_ReturnsSameInstance() {
        // When
        let instance1 = ConfigurationService.shared
        let instance2 = ConfigurationService.shared
        
        // Then
        XCTAssertTrue(instance1 === instance2)
    }
}

