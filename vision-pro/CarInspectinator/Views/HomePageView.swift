//
//  HomePageView.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/30/25.
//

import SwiftUI

struct HopePageView<T>: View where T: HomePageViewModelType {
    @Environment(\.injected) private var injected: CIContainer
    @Environment(AppModel.self) private var appModel
    @StateObject private var vm: T
    
    @State private var path = NavigationPath()
    
    init(vm: T) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("Car Inspectinator")
                    .font(.system(size: 36))
                    .bold()
                    .padding(.init(top: 20, leading: 20, bottom: 0, trailing: 0))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text("Select a car to inspect")
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.leading, 20)
                
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(minimum: 100, maximum: .infinity)),
                            GridItem(.flexible(minimum: 100, maximum: .infinity)),
                            GridItem(.flexible(minimum: 100, maximum: .infinity)),
                            GridItem(.flexible(minimum: 100, maximum: .infinity))
                        ],
                        alignment: .leading,
                        spacing: 10
                    ) {
                        ForEach(vm.cars, id: \.self) { car in
                            CarCard(car: car)
                        }
                    }.padding()
                }
            }
            .navigationDestination(for: Car.self) { car in
                CarDetailedView(car: car)
                    .navigationBarBackButtonHidden()
            }
            .onChange(of: appModel.selectedCar) { _, newValue in
                guard let car = newValue else { return }
                path.append(car)
            }
            .onChange(of: path) { oldPath, newPath in
                // Clear selectedCar when navigating back
                if newPath.count < oldPath.count {
                    appModel.selectedCar = nil
                }
            }
            .task {
                await getCars()
            }
            .safeAreaBar(edge: .bottom, content: errorView)
            .overlay {
                if vm.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

extension HopePageView {
    
    @ViewBuilder
    func errorView() -> some View {
        if let error = vm.error {
            HStack {
                VStack(alignment: .leading) {
                    Text("Error!")
                        .font(.title)
                        .foregroundStyle(.red)
                    Text("Could not retreive cars. Please try again.")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.8))
                    Text("Error: \(error.localizedDescription)")
                        .font(.caption)
                        .foregroundStyle(.black.opacity(0.8))
                        .padding(.top)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                }
                
                Button {
                    Task { await getCars() }
                } label: {
                    Label("Retry", systemImage: "arrow.trianglehead.2.clockwise")
                }
            }
            
        }
    }
    
    
    func getCars() async {
        do {
            try await vm.getCars()
        } catch {
            withAnimation { vm.error = error }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { self.vm.error = nil }
            }
        }
    }
}

#Preview {
    HopePageView(vm: HomePageViewModel(carService: CarService(networkHandler: NetworkHandler(), logger: LoggingService.shared)))
        .environment(AppModel())
}
