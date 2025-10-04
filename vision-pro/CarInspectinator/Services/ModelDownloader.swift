//
//  ModelDownloader.swift
//  CarInspectinator
//
//  Service for downloading and caching 3D car models from GCS
//

import Foundation
import RealityKit

/// Manages downloading and caching of 3D car models
@Observable
final class ModelDownloader {
    /// Shared instance
    static let shared = ModelDownloader()
    
    /// Cache directory for downloaded models
    private let cacheDirectory: URL
    
    /// Currently downloading model URLs
    private var activeDownloads: Set<String> = []
    
    /// Download progress for active downloads
    var downloadProgress: [String: Double] = [:]
    
    private init() {
        // Set up cache directory in app's cache folder
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cacheDir.appendingPathComponent("CarModels", isDirectory: true)
        
        // Create cache directory if it doesn't exist
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Get the local cache path for a model
    func cacheURL(for volumeId: String) -> URL {
        return cacheDirectory.appendingPathComponent("\(volumeId).usdz")
    }
    
    /// Check if a model is cached locally
    func isCached(volumeId: String) -> Bool {
        let url = cacheURL(for: volumeId)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Download a model from a URL and cache it locally
    /// - Parameters:
    ///   - url: The signed GCS URL to download from
    ///   - volumeId: The volume ID to use for caching
    /// - Returns: The local file URL if successful, nil otherwise
    func downloadModel(from urlString: String, volumeId: String) async throws -> URL? {
        // Check if already cached
        if isCached(volumeId: volumeId) {
            print("Model '\(volumeId)' already cached")
            return cacheURL(for: volumeId)
        }
        
        // Check if already downloading
        guard !activeDownloads.contains(volumeId) else {
            print("Model '\(volumeId)' is already being downloaded")
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return nil
        }
        
        activeDownloads.insert(volumeId)
        downloadProgress[volumeId] = 0.0
        defer {
            activeDownloads.remove(volumeId)
            downloadProgress.removeValue(forKey: volumeId)
        }
        
        do {
            print("Downloading model '\(volumeId)' from GCS...")
            
            // Download the file
            let (tempURL, response) = try await URLSession.shared.download(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Failed to download model: Invalid response")
                return nil
            }
            
            // Move to cache directory
            let destinationURL = cacheURL(for: volumeId)
            
            // Remove existing file if present
            try? FileManager.default.removeItem(at: destinationURL)
            
            // Move downloaded file to cache
            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            
            print("✅ Model '\(volumeId)' downloaded and cached")
            downloadProgress[volumeId] = 1.0
            
            return destinationURL
            
        } catch {
            print("Error downloading model '\(volumeId)': \(error)")
            throw error
        }
    }
    
    /// Clear cached model
    func clearCache(for volumeId: String) {
        let url = cacheURL(for: volumeId)
        try? FileManager.default.removeItem(at: url)
        print("Cleared cache for model '\(volumeId)'")
    }
    
    /// Clear all cached models
    func clearAllCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        print("Cleared all cached models")
    }
    
    /// Get the size of cached models in MB
    func getCacheSize() -> Double {
        guard let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        let totalSize = files.reduce(0) { total, url in
            let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + fileSize
        }
        
        return Double(totalSize) / (1024 * 1024) // Convert to MB
    }
}

