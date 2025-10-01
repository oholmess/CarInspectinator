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
    
    var body: some View {
        TimelineView(.animation) { context in
            Model3D(named: carVolumeId, bundle: realityKitContentBundle) { model in
                model
                    .resizable()
                    .scaledToFit3D()
                    .rotation3DEffect(.degrees(context.date.timeIntervalSinceReferenceDate * 10), axis: .y)
            } placeholder: {
                ProgressView()
            }
            
        }
    }
}

#Preview {
    CarVolumeView(carVolumeId: "BMW_M4_f82")
        .environment(AppModel())
}
