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
            // Add haptic feedback for better interaction
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onTap()
            }
        }) {
            VStack(spacing: 0) {
                // Food truck icon with selection state
                Image(systemName: "truck.box.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: isSelected ? 36 : 32, height: isSelected ? 36 : 32)
                    .background(isSelected ? Color.red.opacity(0.9) : .red)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                    )
                    .shadow(color: .black.opacity(isSelected ? 0.4 : 0.3), radius: isSelected ? 6 : 3, x: 0, y: isSelected ? 4 : 2)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // Pointer triangle with selection state
                Triangle()
                    .fill(isSelected ? Color.red.opacity(0.9) : .red)
                    .frame(width: isSelected ? 14 : 12, height: isSelected ? 10 : 8)
                    .offset(y: -2)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
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
        // Normal state
        FoodTruckMapMarker(
            foodTruck: FoodTruckListItem(
                id: "1",
                name: "Tasty Tacos",
                description: "Authentic Mexican street food",
                distanceInMiles: 0.5,
                latitude: 37.7749,
                longitude: -122.4194,
                imageUrl: nil,
                cuisineType: .mexican
            ),
            isSelected: false,
            onTap: {}
        )
        
        // Selected state
        FoodTruckMapMarker(
            foodTruck: FoodTruckListItem(
                id: "2",
                name: "Pizza Paradise",
                description: "Wood-fired pizza on wheels",
                distanceInMiles: 1.2,
                latitude: 37.7849,
                longitude: -122.4094,
                imageUrl: nil,
                cuisineType: .pizza
            ),
            isSelected: true,
            onTap: {}
        )
    }
    .padding()
}