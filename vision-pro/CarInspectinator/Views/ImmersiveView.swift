//  ImmersiveView.swift
//  CarInspectinator
//
//  Created by Assistant.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View {
        RealityView { content in
            content.add(createImmersivePicture(imageName : appModel.panoramaImageName ?? ""))
            
//            // Clear any previous content when re-entering
//            content.entities.removeAll()
//
//            guard let name = appModel.panoramaImageName else { return }
//
//            // Load the 360/equirectangular texture from your asset catalog
//            guard let texture = try? await TextureResource(named: name) else { return }
//
//            // Build an unlit material with the texture (no lighting for a skybox)
//            var material = UnlitMaterial()
//            material.color = .init(tint: .white, texture: .init(texture))
//
//            // Create a large sphere and flip its X scale so we see the inside
//            let sphere = ModelEntity(
//                mesh: .generateSphere(radius: 5.0),
//                materials: [material]
//            )
//            sphere.scale = SIMD3<Float>(x: -1, y: 1, z: 1)
//
//            // Add to the scene
//            content.add(sphere)
        }
        // Optional: a simple close control inside the immersive space
//        .overlay(alignment: .topTrailing) {
//            Button("Close") {
//                Task { await dismissImmersiveSpace() }
//            }
//            .buttonStyle(.borderedProminent)
//            .padding()
//        }
        
    }
}

#Preview {
    ImmersiveView().environment(AppModel())
}
