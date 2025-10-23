//
//  FoodTruckDetailLocationCellView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 7/28/24.
//

import SwiftUI

struct FoodTruckDetailLocationCellView: View {
    var icon: String
    var titleText: String
    var titleTextColor: Color?
    var subtitleText: String?
    var accessoryIcon: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .padding([.leading, .trailing])
                
                VStack(alignment: .leading) {
                    Text(titleText)
                        .font(.callout)
                        .foregroundStyle(titleTextColor != nil ? titleTextColor! : .black)
                    
                    if let subtitleText {
                        Text(subtitleText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if let accessoryIcon {
                    Image(systemName: accessoryIcon)
                        .padding(.trailing)
                }

            }
            Divider()
        }
    }
}

#Preview {
    FoodTruckDetailLocationCellView(icon: "mappin.and.ellipse",
                                    titleText: "Navigate to location",
                                    subtitleText: "Located in the Food City parking lot.")
}
