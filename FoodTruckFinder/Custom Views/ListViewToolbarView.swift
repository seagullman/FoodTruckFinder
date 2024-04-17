//
//  ListViewToolbarView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/6/24.
//

import SwiftUI

struct ListViewToolbarView: View {
    
    @Binding var distance: Double
    
    let isLoading: Bool
    
    var body: some View {
        Menu("Filter", systemImage: "slider.vertical.3") {
            Picker("Distance", selection: $distance) {
                Text("1 mile")
                    .tag(1.0)
                
                Text("5 miles") // TODO: get these values from a constants file
                    .tag(5.0)
                
                Text("10 miles")
                    .tag(10.0)
                
                Text("200 miles")
                    .tag(200.0)
            }
        }
        .font(.title2)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(.gray)
        .disabled(isLoading)
    }
}

#Preview {
    ListViewToolbarView(distance: .constant(5.0), isLoading: false)
}
