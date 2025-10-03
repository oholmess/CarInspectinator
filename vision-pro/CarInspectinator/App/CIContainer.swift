//
//  CIContainer.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 10/3/25.
//

import SwiftUI
import Foundation

final class CIContainer: EnvironmentKey {
    static var defaultValue: CIContainer { CIContainer() }
    

    lazy var networkHandler: NetworkHandler = {
        NetworkHandler()
    }()
    
    func makeHomePageView() -> HopePageView<HomePageViewModel> {
        return HopePageView(vm: HomePageViewModel(networkHandler: networkHandler))
    }
    
//    func makeContentView() -> ContentView<ContentViewModel> {
//        return ContentView(viewModel: ContentViewModel(authService: authService))
//    }
//    
//    func makeHomePageView() -> HomePageView<HomePageViewModel> {
//        return HomePageView(viewModel: ContentViewModel(authService: authService))
//    }
}


extension EnvironmentValues {
    var injected: CIContainer {
        get { self[CIContainer.self] }
        set { self[CIContainer.self] = newValue }
    }
}

extension View {
    func addContainer(_ container: CIContainer) -> some View {
        environment(\.injected, container)
    }
}
