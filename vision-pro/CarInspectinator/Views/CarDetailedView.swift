//
//  CarDetailedView.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/24/25.
//

import SwiftUI
import RealityKit

struct CarDetailedView: View {
    let car: Car

    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss

    @State private var isImmersiveModeOn = false
    @State private var isTogglingImmersive = false
    @State private var is3DModelOpen = false
    @State private var isToggling3DModel = false
    @Namespace private var heroNS

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                backButton
                heroHeader
                immersiveSection
                specsSection
                moreSpecsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .animation(.easeInOut(duration: 0.25), value: isImmersiveModeOn)
    }
}

// MARK: - Sections
private extension CarDetailedView {
    var backButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Back", image: "chevron.left")
            }
            
            Spacer()
        }
        .padding(.top)
    }

    var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: [.blue.opacity(0.25), .indigo.opacity(0.25)],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay {
                    carArtwork
                        .matchedGeometryEffect(id: "car-art-\(car.id)", in: heroNS)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityHidden(true)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(car.model)
                    .font(.largeTitle.weight(.bold))
                    .lineLimit(2)
                Text([car.make, car.year.map(String.init)].compactMap{$0}.joined(separator: " • "))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 8, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(car.make) \(car.model), \(car.year.map(String.init) ?? "Year unknown")")
    }

    var specsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specifications")
                .font(.headline)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: 12, alignment: .leading)],
                alignment: .leading,
                spacing: 12
            ) {
                ForEach(specItems(), id: \.label) { item in
                    specChip(item)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var moreSpecsSection: some View {
        VStack {
            Text("Other Specifications")
                .font(.headline)
            
                ForEach(Array(car.otherSpecs.keys), id: \.self) { key in
                        HStack {
                            Text(key + ":")
                            Text(car.otherSpecs[key] ?? "")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
        }
    }

    var immersiveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Experience")
                .font(.headline)

            HStack(spacing: 12) {
                Button {
                    Task { await toggleImmersiveSpace() }
                } label: {
                    Label(isImmersiveModeOn ? "Close Immersive Space" : "Open Immersive Space",
                          systemImage: isImmersiveModeOn ? "xmark.circle.fill" : "move.3d")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isTogglingImmersive)
                .opacity(isTogglingImmersive ? 0.6 : 1)
                .accessibilityHint(isImmersiveModeOn ? "Closes 3D immersive view" : "Opens 3D immersive view")

                if isTogglingImmersive || isToggling3DModel {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 28, height: 28)
                        .accessibilityLabel("Loading")
                }
                
                Button {
                    Task { await toggle3dModel() }
                } label: {
                    Label(is3DModelOpen ? "Close 3D Model" : "Open 3D Model",
                          systemImage: is3DModelOpen ? "car.fill" : "car")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isTogglingImmersive)
                .opacity(isTogglingImmersive ? 0.6 : 1)
                .accessibilityHint(isImmersiveModeOn ? "Closes 3D immersive view" : "Opens 3D immersive view")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews & Helpers
private extension CarDetailedView {

    var carArtwork: some View {
        Group {
            if let icon = car.iconAssetName, !icon.isEmpty {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .transition(.scale.combined(with: .opacity))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                    VStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 44, weight: .semibold))
                        Text("No Image")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .frame(height: 220)
            }
        }
        .padding(.horizontal, 8)
    }

    struct SpecItem {
        let label: String
        let value: String
        let icon: String
    }

    func specItems() -> [SpecItem] {
        [
            SpecItem(label: "Horsepower", value: car.performance?.horsepower.map { "\($0) hp" } ?? "—", icon: "speedometer"),
            SpecItem(label: "Body Style", value: car.bodyStyle?.rawValue ?? "—", icon: "car.side"),
            SpecItem(label: "Year", value: car.year.map(String.init) ?? "—", icon: "calendar"),
            SpecItem(label: "Engine Fuel Type", value: car.engine?.fuel?.rawValue ?? "—", icon: "engine.combustion"),
            SpecItem(label: "Engine Cynlinders Count", value: String(car.engine?.cylinders ?? 0), icon: "bolt.fill")
        ]
    }

    @ViewBuilder
    func specChip(_ item: SpecItem) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Image(systemName: item.icon)
                    .imageScale(.medium)
                    .frame(width: 20)
                
                Text(item.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .opacity(0.7)
                Text(item.value)
                    .font(.callout.weight(.semibold))
                    .contentTransition(.numericText(value: 10))
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.label): \(item.value)")
    }

    func toggleImmersiveSpace() async {
        guard !isTogglingImmersive else { return }
        isTogglingImmersive = true
        defer { isTogglingImmersive = false }

        if isImmersiveModeOn {
            await dismissImmersiveSpace()
            isImmersiveModeOn = false
        } else {
            await openImmersiveSpace(id: appModel.immersiveSpaceID)
            // If your API returns a result enum, check it here for success:
            // if case .opened = result { isImmersiveModeOn = true }
            // Fallback: assume success
            isImmersiveModeOn = true
        }
    }
    
    func toggle3dModel() async {
        guard !isToggling3DModel else { return }
        isToggling3DModel = true
        defer { isToggling3DModel = false }
        
        if is3DModelOpen {
            is3DModelOpen = false
        } else {
            if let volumeId = appModel.selectedCar?.volumeId {
                print("volumeId: ", volumeId)
                openWindow(id: volumeId)
            } else {
                print("no volume ID, selected car: ", appModel.selectedCar ?? "n")
                is3DModelOpen = false
            }
            // If your API returns a result enum, check it here for success:
            // if case .opened = result { isImmersiveModeOn = true }
            // Fallback: assume success
            is3DModelOpen = true
        }
        
    }
}

// MARK: - Preview
#Preview(windowStyle: .automatic) {
    NavigationStack {
        CarDetailedView(car: cars[0])
            .environment(AppModel())
            .padding()
    }
}
