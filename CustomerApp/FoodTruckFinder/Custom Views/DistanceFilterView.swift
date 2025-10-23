//
//  DistanceFilterView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 1/20/25.
//

import SwiftUI

struct DistanceFilterView: View {

    @EnvironmentObject var sharedDataModel: SharedDataModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select search distance")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            ForEach(Constants.distanceFilterOptions) { option in
                Button(action: {
                    sharedDataModel.distanceFilterOption = option
                    isPresented = false
                }) {
                    HStack {
                        Text(option.text)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(option == sharedDataModel.distanceFilterOption ? .white : .primary)
                        
                        Spacer()
                        
                        if option == sharedDataModel.distanceFilterOption {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(option == sharedDataModel.distanceFilterOption ? Color.red : Color(.systemGray6))
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    DistanceFilterView(isPresented: .constant(true))
        .environmentObject(SharedDataModel())
}
