//
//  LocationsListView.swift
//  SwiftfulMapApp
//
//  Created by Nick Sarno on 11/27/21.
//

import SwiftUI

struct LocationsListView: View {
    
    var viewModel: MapView.ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.foodTruckListItems) { item in
                Button {
                    viewModel.showNextItem(item: item)
                } label: {
                    listRowView(item: item)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }
}

extension LocationsListView {
    
    private func listRowView(item: FoodTruckListItem) -> some View {
        HStack {
            if let imageUrlString = item.imageUrl,
               let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 45, height: 45)
                        .cornerRadius(12)
                } placeholder: {
                    ProgressView()
                        .frame(width: 45, height: 45)
                }

            } else {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.secondary)
                    .frame(width: 45, height: 45)
            }
            
            Text(item.name)
                .font(.headline)
            
            Spacer()
            
            Text(String(format: "%.1f mi", item.distanceInMiles))
                .font(.subheadline)
            
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
}
