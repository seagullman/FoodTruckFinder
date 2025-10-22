//
//  FoodTruckCompactOverlay.swift
//  FoodTruckFinder
//
//  Created by Kiro on 1/15/25.
//

import SwiftUI

struct FoodTruckCompactOverlay: View {
    let foodTruck: FoodTruckListItem
    let onViewDetails: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Food truck icon with modern design
            Image(systemName: "truck.box.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 44, height: 44)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                // Food truck name
                Text(foodTruck.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    // Cuisine type
                    if let cuisineType = foodTruck.cuisineType {
                        Text(cuisineType.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Distance
                    Text("• \(foodTruck.distanceInMiles.formatted(.number.precision(.fractionLength(1)))) mi")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons with modern design
            HStack(spacing: 8) {
                // View Details button
                Button(action: onViewDetails) {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.red)
                    )
                }
                .buttonStyle(.plain)
                
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(.systemGray6))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack {
        Spacer()
        
        FoodTruckCompactOverlay(
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
        .padding(.bottom, 100)
    }
    .background(
        LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    )
}