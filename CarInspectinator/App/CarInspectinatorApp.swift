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
            CarVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
//        .defaultSize(width: 2, height: 1, depth: 2, in: .meters)
        
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
