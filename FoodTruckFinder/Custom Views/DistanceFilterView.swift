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
        VStack(alignment: .leading, spacing: 12) { // Adds spacing between options
            Text("Select search distance")
                .font(.subheadline)
                .padding(.bottom)
            ForEach(Constants.distanceFilterOptions) { option in
                Button(action: {
                    sharedDataModel.distanceFilterOption = option
                    isPresented = false
                }) {
                    HStack {
                        Text(option.text)
                            .font(.headline)
                            .foregroundColor(.white).bold()
                        Spacer()
                        if option == sharedDataModel.distanceFilterOption {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white) // Make checkmark stand out
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.red) // Light red background
                    .cornerRadius(12) // Rounded corners
                }
                .buttonStyle(.plain) // Removes default button styling
            }
        }
        .padding(.horizontal) // Adds spacing on the sides
    }
}

#Preview {
    DistanceFilterView(isPresented: .constant(true))
        .environmentObject(SharedDataModel())
}
