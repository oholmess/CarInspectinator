//
//  Util.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/29/25.
//

import Foundation
import RealityKit

func createImmersivePicture(imageName : String) -> Entity {
    let modelEntity = Entity()
    let texture = try? TextureResource.load(named: imageName)
    var material = UnlitMaterial()
    material.color = .init(texture: .init(texture!))
    modelEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 1E3), materials: [material]))
    modelEntity.scale = .init(x: -10, y: 10, z: 10)
    modelEntity.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
    return modelEntity
}
