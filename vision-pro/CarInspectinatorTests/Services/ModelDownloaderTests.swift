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
    
    func testGetCacheSize_ReturnsValue() async {
        // When
        let size = await sut.getCacheSize()
        
        // Then
        // Size should be >= 0 (non-negative)
        XCTAssertGreaterThanOrEqual(size, 0)
    }
    
    // MARK: - clearCache Tests
    
    func testClearCache_DoesNotThrow() {
        // Given
        let volumeId = "test-volume"
        
        // When/Then - Should not throw
        sut.clearCache(for: volumeId)
    }
    
    func testClearAllCache_DoesNotThrow() {
        // When/Then - Should not throw
        sut.clearAllCache()
    }
}
