//
//  ImmersizeCarView.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/29/25.
//

import SwiftUI
import RealityKit

struct ImmersizeCarView: View {
    @State private var currentImmersionStyle: ImmersionStyle = .full
    
    var body: some View {

    }
}

#Preview {
    ImmersizeCarView()
}


struct ImageImmersiveView: View {
    var iconName: String
    
    var body: some View {
        RealityView { content in
            content.add(createImmersivePicture(imageName: iconName))
        }
    }
    
}
