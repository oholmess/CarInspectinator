//
//  CarInspectinatorApp.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/23/25.
//

import SwiftUI

@main
struct CarInspectinatorApp: App {
    
    @State private var appModel = AppModel()
    @State private var avPlayerViewModel = AVPlayerViewModel()
    @State private var currentImmersionStyle: ImmersionStyle = .full
    
    public static let volkswagenGti = "vw_golf_5_gti"
    public static let bmwm4 = "BMW_M4_f82"
    
    var body: some Scene {
        WindowGroup {
            if avPlayerViewModel.isPlaying {
                AVPlayerView(viewModel: avPlayerViewModel)
            } else {
                ContentView()
                    .environment(appModel)
            }
        }
        
        WindowGroup(id: Self.volkswagenGti) {
            CarVolumeView(carVolumeId: Self.volkswagenGti)
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
        
        WindowGroup(id: Self.bmwm4) {
            CarVolumeView(carVolumeId: Self.bmwm4)
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open

                    // Only start the player for video-based immersive content
                    // e.g., if you add a flag like `appModel.isVideoImmersion`
                    if appModel.panoramaImageName == nil {
                        avPlayerViewModel.play()
                    }
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                    avPlayerViewModel.reset()
                }
        }
        .immersionStyle(selection: $currentImmersionStyle, in: .full)
        
    }
}
