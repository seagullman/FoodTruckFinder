//
//  FoodTruckBottomOverlay.swift
//  FoodTruckFinder
//
//  Created by Kiro on 1/15/25.
//

import SwiftUI

struct FoodTruckBottomOverlay: View {
    let foodTruck: FoodTruckListItem
    let onViewDetails: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            HStack(spacing: 16) {
                // Food truck icon
                Image(systemName: "truck.box.fill")
                    .font(.title)
                    .foregroundColor(.red)
                    .frame(width: 50, height: 50)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    // Food truck name
                    Text(foodTruck.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    // Cuisine type
                    if let cuisineType = foodTruck.cuisineType {
                        Text(cuisineType.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Distance
                    Text("\(foodTruck.distanceInMiles.formatted(.number.precision(.fractionLength(1)))) miles away")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // View Details button
            Button(action: onViewDetails) {
                HStack(spacing: 8) {
                    Text("View Details")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.red)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    VStack {
        Spacer()
        FoodTruckBottomOverlay(
            foodTruck: FoodTruckListItem(
                id: "1",
                name: "Tasty Tacos Truck",
                description: "Authentic Mexican street food with fresh ingredients",
                distanceInMiles: 0.5,
                latitude: 37.7749,
                longitude: -122.4194,
                imageUrl: nil,
                cuisineType: .mexican
            ),
            onViewDetails: {},
            onClose: {}
        )
    }
    .background(Color.blue.opacity(0.3))
}