//
//  ModelDownloader.swift
//  CarInspectinator
//
//  Refactored to follow Dependency Inversion and Single Responsibility principles
//

import Foundation
import RealityKit

// MARK: - Protocol (Dependency Inversion)

protocol ModelDownloaderProtocol {
    var downloadProgress: [String: Double] { get }
    func cacheURL(for volumeId: String) -> URL
    func isCached(volumeId: String) -> Bool
    func downloadModel(from urlString: String, volumeId: String) async throws -> URL?
    func clearCache(for volumeId: String) throws
    func clearAllCache() throws
    func getCacheSize() -> Double
}

// MARK: - Implementation

@Observable
final class ModelDownloader: ModelDownloaderProtocol {
    private let cacheDirectory: URL
    private let fileManager: FileManager
    private let urlSession: URLSession
    private let logger: LoggerProtocol
    
    private var activeDownloads: Set<String> = []
    var downloadProgress: [String: Double] = [:]
    
    init(
        configuration: ConfigurationServiceProtocol = ConfigurationService.shared,
        fileManager: FileManager = .default,
        urlSession: URLSession = .shared,
        logger: LoggerProtocol = LoggerFactory.shared.logger(for: "ModelDownloader")
    ) {
        self.cacheDirectory = configuration.cacheDirectory
        self.fileManager = fileManager
        self.urlSession = urlSession
        self.logger = logger
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    func cacheURL(for volumeId: String) -> URL {
        cacheDirectory.appendingPathComponent("\(volumeId).usdz")
    }
    
    func isCached(volumeId: String) -> Bool {
        let url = cacheURL(for: volumeId)
        return fileManager.fileExists(atPath: url.path)
    }
    
    func downloadModel(from urlString: String, volumeId: String) async throws -> URL? {
        // Check if already cached
        if isCached(volumeId: volumeId) {
            logger.info("Model '\(volumeId)' already cached", file: #file, function: #function, line: #line)
            return cacheURL(for: volumeId)
        }
        
        // Check if already downloading
        guard !activeDownloads.contains(volumeId) else {
            logger.warning("Model '\(volumeId)' is already being downloaded", file: #file, function: #function, line: #line)
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL: \(urlString)", file: #file, function: #function, line: #line)
            throw NetworkError.userError("Invalid URL")
        }
        
        activeDownloads.insert(volumeId)
        downloadProgress[volumeId] = 0.0
        defer {
            activeDownloads.remove(volumeId)
            downloadProgress.removeValue(forKey: volumeId)
        }
        
        do {
            logger.info("Downloading model '\(volumeId)' from GCS", file: #file, function: #function, line: #line)
            
            let (tempURL, response) = try await urlSession.download(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                logger.error("Failed to download model: Invalid response", file: #file, function: #function, line: #line)
                throw NetworkError.noResponse
            }
            
            let destinationURL = cacheURL(for: volumeId)
            
            // Remove existing file if present
            try? fileManager.removeItem(at: destinationURL)
            
            // Move downloaded file to cache
            try fileManager.moveItem(at: tempURL, to: destinationURL)
            
            logger.info("✅ Model '\(volumeId)' downloaded and cached", file: #file, function: #function, line: #line)
            downloadProgress[volumeId] = 1.0
            
            return destinationURL
            
        } catch {
            logger.error("Error downloading model '\(volumeId)': \(error.localizedDescription)", file: #file, function: #function, line: #line)
            throw error
        }
    }
    
    func clearCache(for volumeId: String) throws {
        let url = cacheURL(for: volumeId)
        try fileManager.removeItem(at: url)
        logger.info("Cleared cache for model '\(volumeId)'", file: #file, function: #function, line: #line)
    }
    
    func clearAllCache() throws {
        try fileManager.removeItem(at: cacheDirectory)
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        logger.info("Cleared all cached models", file: #file, function: #function, line: #line)
    }
    
    func getCacheSize() -> Double {
        guard let files = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }
        
        let totalSize = files.reduce(0) { total, url in
            let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + fileSize
        }
        
        return Double(totalSize) / (1024 * 1024) // Convert to MB
    }
}

