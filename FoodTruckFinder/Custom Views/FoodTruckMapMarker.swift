//
//  FoodTruckMapMarker.swift
//  FoodTruckFinder
//
//  Created by Kiro on 1/15/25.
//

import SwiftUI

struct FoodTruckMapMarker: View {
    let foodTruck: FoodTruckListItem
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onTap()
            }
        }) {
            VStack(spacing: 0) {
                // Food truck logo or fallback icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color.red : Color.white)
                        .frame(width: isSelected ? 40 : 36, height: isSelected ? 40 : 36)
                        .shadow(color: .black.opacity(isSelected ? 0.2 : 0.15), radius: isSelected ? 8 : 6, x: 0, y: isSelected ? 4 : 3)
                    
                    if let imageUrlString = foodTruck.imageUrl, let url = URL(string: imageUrlString) {
                        // Show actual food truck logo
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: isSelected ? 36 : 32, height: isSelected ? 36 : 32)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } placeholder: {
                            // Fallback to truck icon while loading
                            Image(systemName: "truck.box.fill")
                                .font(.system(size: isSelected ? 16 : 14, weight: .medium))
                                .foregroundColor(isSelected ? .white : .primary)
                        }
                    } else {
                        // Fallback to truck icon when no image
                        Image(systemName: "truck.box.fill")
                            .font(.system(size: isSelected ? 16 : 14, weight: .medium))
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? Color.white : Color.red.opacity(0.6), lineWidth: isSelected ? 2 : 1.5)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Pointer triangle with modern design
                Triangle()
                    .fill(isSelected ? Color.red : Color.white)
                    .frame(width: isSelected ? 16 : 14, height: isSelected ? 12 : 10)
                    .offset(y: -1)
                    .overlay(
                        Triangle()
                            .stroke(isSelected ? Color.white : Color.red.opacity(0.6), lineWidth: isSelected ? 2 : 1.5)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// Helper view for the map marker pointer
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    HStack(spacing: 20) {
        // Normal state with image
        FoodTruckMapMarker(
            foodTruck: FoodTruckListItem(
                id: "1",
                name: "Tasty Tacos",
                description: "Authentic Mexican street food",
                distanceInMiles: 0.5,
                latitude: 37.7749,
                longitude: -122.4194,
                imageUrl: "https://example.com/taco-truck.jpg",
                cuisineType: .mexican
            ),
            isSelected: false,
            onTap: {}
        )
        
        // Selected state with image
        FoodTruckMapMarker(
            foodTruck: FoodTruckListItem(
                id: "2",
                name: "Pizza Paradise",
                description: "Wood-fired pizza on wheels",
                distanceInMiles: 1.2,
                latitude: 37.7849,
                longitude: -122.4094,
                imageUrl: "https://example.com/pizza-truck.jpg",
                cuisineType: .pizza
            ),
            isSelected: true,
            onTap: {}
        )
        
        // Normal state without image (fallback)
        FoodTruckMapMarker(
            foodTruck: FoodTruckListItem(
                id: "3",
                name: "Coffee Corner",
                description: "Artisan coffee and pastries",
                distanceInMiles: 0.8,
                latitude: 37.7949,
                longitude: -122.4294,
                imageUrl: nil,
                cuisineType: .coffee
            ),
            isSelected: false,
            onTap: {}
        )
    }
    .padding()
}