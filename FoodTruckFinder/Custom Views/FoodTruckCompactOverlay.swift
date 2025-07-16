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
        HStack(spacing: 12) {
            // Food truck icon
            Image(systemName: "truck.box.fill")
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                // Food truck name
                Text(foodTruck.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    // Cuisine type
                    if let cuisineType = foodTruck.cuisineType {
                        Text(cuisineType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Distance
                    Text("• \(foodTruck.distanceInMiles.formatted(.number.precision(.fractionLength(1)))) mi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                // View Details button
                Button(action: onViewDetails) {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red)
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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