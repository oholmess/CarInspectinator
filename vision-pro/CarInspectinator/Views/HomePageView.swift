//
//  HomePageView.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/30/25.
//

import SwiftUI

struct HopePageView: View {
    @Environment(AppModel.self) private var appModel
    
    @State private var path = NavigationPath()
    
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
                        ForEach(carsArray, id: \.self) { car in
                            CarCard(car: car)
                        }
                    }.padding()
                }
            }
            .navigationDestination(for: Car.self) { car in
                CarDetailedView(car: car)
            }
            .onChange(of: appModel.selectedCar) { _, newValue in
                guard let car = newValue else { return }
                path.append(car)

                // Defer the reset to avoid mutating during the same update cycle
//                DispatchQueue.main.async {
//                    appModel.selectedCar = nil
//                }
            }
        }
    }
}

#Preview {
    HopePageView()
        .environment(AppModel())
}
