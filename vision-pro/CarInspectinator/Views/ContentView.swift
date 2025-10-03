//
//  ContentView.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/23/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.injected) private var injected: CIContainer
    @State private var path = NavigationPath()

    var body: some View {
        injected.makeHomePageView().environment(appModel)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
