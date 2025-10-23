//
//  FoodTruckMapDetailSheet.swift
//  FoodTruckFinder
//
//  Created by Kiro on 1/15/25.
//

import SwiftUI

struct FoodTruckMapDetailSheet: View {
    let foodTruck: FoodTruckListItem
    let onNavigateToDetail: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Main content
            VStack(spacing: 20) {
                // Header with image and basic info
                HStack(spacing: 16) {
                    // Food truck image or icon
                    if let imageUrlString = foodTruck.imageUrl, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "truck.box.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                )
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "truck.box.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // Food truck name
                        Text(foodTruck.name)
                            .font(.system(size: 18, weight: .bold))
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        // Cuisine type and distance
                        HStack(spacing: 12) {
                            if let cuisineType = foodTruck.cuisineType {
                                HStack(spacing: 4) {
                                    Image(systemName: cuisineType.iconName)
                                        .font(.system(size: 12, weight: .medium))
                                    Text(cuisineType.displayName)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12, weight: .medium))
                                Text("\(foodTruck.distanceInMiles.formatted(.number.precision(.fractionLength(1)))) mi")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Description
                if !foodTruck.description.isEmpty {
                    Text(foodTruck.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Action button
                Button(action: onNavigateToDetail) {
                    HStack(spacing: 8) {
                        Text("View Full Details")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.red)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#Preview {
    FoodTruckMapDetailSheet(
        foodTruck: FoodTruckListItem(
            id: "1",
            name: "Tasty Tacos Truck",
            description: "Authentic Mexican street food with fresh ingredients and homemade tortillas. We serve the best tacos in town!",
            distanceInMiles: 0.5,
            latitude: 37.7749,
            longitude: -122.4194,
            imageUrl: nil,
            cuisineType: .mexican
        ),
        onNavigateToDetail: {}
    )
    .frame(height: 220)
    .padding()
}