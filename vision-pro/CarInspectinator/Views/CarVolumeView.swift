//
//  CarVolumeView.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/30/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct CarVolumeView: View {
    @Environment(AppModel.self) private var appModel
    
    let carVolumeId: String
    
    @State private var modelEntity: ModelEntity?
    @State private var isLoading = false
    @State private var loadError: String?
    
    // Get the car from appModel.selectedCar if it matches this volumeId
    private var car: Car? {
        guard let selectedCar = appModel.selectedCar,
              selectedCar.volumeId == carVolumeId else {
            return nil
        }
        return selectedCar
    }
    
    var body: some View {
        ZStack {
            if let modelEntity = modelEntity {
                TimelineView(.animation) { context in
                    RealityView { content in
                        // Add the model entity only once
                        if content.entities.isEmpty {
                            content.add(modelEntity)
                        }
                    } update: { content in
                        // Update rotation
                        modelEntity.transform.rotation = simd_quatf(
                            angle: Float(context.date.timeIntervalSinceReferenceDate * 0.5),
                            axis: [0, 1, 0]
                        )
                    }
                }
            } else if isLoading {
                ProgressView("Loading 3D model...")
            } else if let error = loadError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                    Text("Failed to load model")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                // Fallback: Try loading from bundle
                TimelineView(.animation) { context in
                    Model3D(named: carVolumeId, bundle: realityKitContentBundle) { model in
                        model
                            .resizable()
                            .scaledToFit3D()
                            .rotation3DEffect(.degrees(context.date.timeIntervalSinceReferenceDate * 30), axis: .y)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
        }
        .task {
            await loadModel()
        }
    }
    
    @MainActor
    private func loadModel() async {
        guard modelEntity == nil else { return }
        
        isLoading = true
        loadError = nil
        
        do {
            // Priority 1: Load from URL if available
            if let car = car, let modelUrl = car.modelUrl, !modelUrl.isEmpty {
                print("Loading model from URL: \(modelUrl)")
                if let localURL = try await downloadModelIfNeeded(from: modelUrl, volumeId: carVolumeId) {
                    modelEntity = try await loadModelFromFile(url: localURL)
                    isLoading = false
                    return
                }
            }
            
            // Priority 2: Load from cache if available
            let downloader = ModelDownloader.shared
            if downloader.isCached(volumeId: carVolumeId) {
                print("Loading model from cache: \(carVolumeId)")
                let cachedURL = downloader.cacheURL(for: carVolumeId)
                modelEntity = try await loadModelFromFile(url: cachedURL)
                isLoading = false
                return
            }
            
            // Priority 3: Load from bundle (fallback)
            print("Loading model from bundle: \(carVolumeId)")
            modelEntity = try await loadModelFromBundle(named: carVolumeId)
            isLoading = false
            
        } catch {
            print("Error loading model: \(error)")
            loadError = error.localizedDescription
            isLoading = false
        }
    }
    
    private func downloadModelIfNeeded(from urlString: String, volumeId: String) async throws -> URL? {
        let downloader = ModelDownloader.shared
        
        // Check cache first
        if downloader.isCached(volumeId: volumeId) {
            return downloader.cacheURL(for: volumeId)
        }
        
        // Download if not cached
        return try await downloader.downloadModel(from: urlString, volumeId: volumeId)
    }
    
    private func loadModelFromFile(url: URL) async throws -> ModelEntity {
        let entity = try await ModelEntity(contentsOf: url)
        entity.scale = SIMD3(repeating: 1.0)
        return entity
    }
    
    private func loadModelFromBundle(named name: String) async throws -> ModelEntity {
        guard let entity = try? await ModelEntity(named: name, in: realityKitContentBundle) else {
            throw ModelLoadError.notFoundInBundle
        }
        entity.scale = SIMD3(repeating: 1.0)
        return entity
    }
}

enum ModelLoadError: LocalizedError {
    case notFoundInBundle
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .notFoundInBundle:
            return "Model not found in app bundle"
        case .downloadFailed:
            return "Failed to download model"
        }
    }
}

#Preview {
    CarVolumeView(carVolumeId: "BMW_M4_f82")
        .environment(AppModel())
}
