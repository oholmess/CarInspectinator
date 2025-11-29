//
//  MockModelDownloader.swift
//  CarInspectinatorTests
//
//  Mock implementation of ModelDownloaderProtocol for testing
//

import Foundation
@testable import CarInspectinator

final class MockModelDownloader: ModelDownloaderProtocol {
    var downloadProgress: [String: Double] = [:]
    
    // Configure mock behavior
    var mockCachedFiles: Set<String> = []
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.noResponse
    var downloadDelay: TimeInterval = 0
    
    // Track calls
    var downloadCallCount = 0
    var lastDownloadURL: String?
    var lastVolumeId: String?
    
    func cacheURL(for volumeId: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("TestCache")
            .appendingPathComponent("\(volumeId).usdz")
    }
    
    func isCached(volumeId: String) -> Bool {
        mockCachedFiles.contains(volumeId)
    }
    
    func downloadModel(from urlString: String, volumeId: String) async throws -> URL? {
        downloadCallCount += 1
        lastDownloadURL = urlString
        lastVolumeId = volumeId
        
        if downloadDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(downloadDelay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        mockCachedFiles.insert(volumeId)
        return cacheURL(for: volumeId)
    }
    
    func clearCache(for volumeId: String) throws {
        mockCachedFiles.remove(volumeId)
    }
    
    func clearAllCache() throws {
        mockCachedFiles.removeAll()
    }
    
    func getCacheSize() -> Double {
        Double(mockCachedFiles.count) * 10.0 // 10MB per file
    }
    
    // Helper methods
    func reset() {
        mockCachedFiles.removeAll()
        shouldThrowError = false
        downloadCallCount = 0
        lastDownloadURL = nil
        lastVolumeId = nil
        downloadProgress.removeAll()
    }
}

