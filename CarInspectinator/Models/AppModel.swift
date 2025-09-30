//
//  AppModel.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/23/25.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed

    var selectedCar: Car? = nil
    var panoramaImageName: String? = "test_view"

    func selectCar(_ car: Car) {
        selectedCar = car
        immersiveSpaceState = .inTransition
    }

    func resetSelection() {
        selectedCar = nil
        immersiveSpaceState = .closed
    }
}

