//
//  CarCard.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 9/23/25.
//

import SwiftUI

struct CarCard: View {
    let car: Car
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack {
            Image(car.icon ?? "")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, -10)
            
            HStack {
                VStack {
                    Text(car.model)
                        .font(.system(size: 26))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                    
                    Text(car.make)
                        .font(.system(size: 18))
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                }
                
                Button {
                    appModel.selectCar(car)
                } label: {
                    Label("Inspect", systemImage: "eye")
                        .labelStyle(.titleOnly)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.vertical, 15)
                }
                .padding()
            
            }
                
        }
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.black.opacity(0.8))
        }
    }
}

#Preview {
    CarCard(car: carsArray[0])
}
