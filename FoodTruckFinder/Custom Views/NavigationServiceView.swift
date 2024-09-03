//
//  NavigationServiceView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 8/7/24.
//
import SwiftUI

struct NavigationServiceView: View {
    
    @EnvironmentObject var sharedDataModel: SharedDataModel
    
    var body: some View {
        ForEach(NavigationMapService.allCases, id: \.self) { service in
            HStack {
//                Image(systemName: "gear")
//                    .foregroundColor(.gray)
                Text(service.rawValue)
                
                Spacer()
                
                if sharedDataModel.navigationMapService == service {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.black)
                }
            }
            .contentShape(Rectangle()) // Makes the whole row tappable
            .onTapGesture {
                sharedDataModel.navigationMapService = service
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Navigation Service")
    }
}

#Preview {
    NavigationServiceView()
}
