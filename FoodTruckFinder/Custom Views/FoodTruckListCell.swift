//
//  FoodTruckListCell.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI

struct FoodTruckListCell: View {
    
    let listItem: FoodTruckListItem
    
    var body: some View {
        HStack {
            if let imageUrlString = listItem.imageUrl,
               let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                        .cornerRadius(12)
                } placeholder: {
                    ProgressView()
                        .frame(width: 75, height: 75)
                }

            } else {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.secondary)
                    .frame(width: 75, height: 75)
            }

            VStack(alignment: .leading) {
                Text(listItem.name)
                Text(listItem.description)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.1f mi", listItem.distanceInMiles))
                .font(.system(.subheadline))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    FoodTruckListCell(listItem: FoodTruckListItem(id: "1234", name: "Brad's Food Truck", description: "Best food south of the river!", distanceInMiles: 6.5, latitude: 123, longitude: 456, imageUrl: ""))
}
