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
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.secondary)
                .frame(width: 75, height: 75)
//                .padding(.leading, 20)
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
    FoodTruckListCell(listItem: FoodTruckListItem(id: "1234", name: "Brad's Food Truck", description: "Best food south of the river!", distanceInMiles: 6.5))
}
