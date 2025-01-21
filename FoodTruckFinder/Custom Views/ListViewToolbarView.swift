//
//  ListViewToolbarView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/6/24.
//

import SwiftUI

struct ListViewToolbarView: View {
    
    @EnvironmentObject var sharedDataModel: SharedDataModel
    
    let isLoading: Bool
    
    var body: some View {
        Menu("Filter", systemImage: "slider.vertical.3") {
            Picker("Distance", selection: $sharedDataModel.distanceFilterOption) {
                ForEach(Constants.distanceFilterOptions) { option in
                    Text(option.text)
                        .tag(option)
                }
            }
        }
        .font(.title2)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(.gray)
        .disabled(isLoading)
    }
}

//Text("1 mile")
//    .tag(1.0)
#Preview {
    ListViewToolbarView(isLoading: false)
}
