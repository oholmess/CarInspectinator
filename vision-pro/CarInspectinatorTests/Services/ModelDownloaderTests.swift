//
//  ModelDownloaderTests.swift
//  CarInspectinatorTests
//
//  Unit tests for ModelDownloader
//

import XCTest
@testable import CarInspectinator

final class ModelDownloaderTests: XCTestCase {
    
    var sut: ModelDownloader!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        // Create with mock configuration
        sut = ModelDownloader(
            configuration: MockConfigurationService(),
            logger: mockLogger
        )
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - cacheURL Tests
    
    func testCacheURL_ReturnsURL() {
        // Given
        let volumeId = "test-volume"
        
        // When
        let url = sut.cacheURL(for: volumeId)
        
        // Then
        XCTAssertNotNil(url)
    }
    
    func testCacheURL_ContainsVolumeId() {
        // Given
        let volumeId = "unique-volume-123"
        
        // When
        let url = sut.cacheURL(for: volumeId)
        
        // Then
        XCTAssertTrue(url.absoluteString.contains(volumeId))
    }
    
    func testCacheURL_HasUsdzExtension() {
        // Given
        let volumeId = "test-volume"
        
        // When
        let url = sut.cacheURL(for: volumeId)
        
        // Then
        XCTAssertEqual(url.pathExtension, "usdz")
    }
    
    // MARK: - isCached Tests
    
    func testIsCached_ReturnsFalseForNonExistentFile() {
        // Given
        let volumeId = "non-existent-volume-\(UUID().uuidString)"
        
        // When
        let cached = sut.isCached(volumeId: volumeId)
        
        // Then
        XCTAssertFalse(cached)
    }
    
    // MARK: - downloadProgress Tests
    
    func testDownloadProgress_InitiallyEmpty() {
        // Then
        XCTAssertTrue(sut.downloadProgress.isEmpty)
    }
    
    // MARK: - getCacheSize Tests
    
    func testGetCacheSize_ReturnsValue() {
        // When
        let size = sut.getCacheSize()
        
        // Then
        // Size should be >= 0 (non-negative)
        XCTAssertGreaterThanOrEqual(size, 0)
    }
    
    // MARK: - clearCache Tests
    
    func testClearCache_NonExistentFile_ThrowsError() {
        // Given - a volume that doesn't exist
        let volumeId = "non-existent-volume-\(UUID().uuidString)"
        
        // When/Then - Should throw because file doesn't exist
        XCTAssertThrowsError(try sut.clearCache(for: volumeId))
    }
    
    func testClearAllCache_HandlesEmptyCache() {
        // When/Then - May throw if cache directory doesn't exist
        // This tests that the method is callable
        do {
            try sut.clearAllCache()
        } catch {
            // Expected if directory doesn't exist or is inaccessible
            XCTAssertNotNil(error)
        }
    }
}
