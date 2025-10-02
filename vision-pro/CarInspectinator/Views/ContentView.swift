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
    @State private var path = NavigationPath()

    var body: some View {
        HopePageView()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
