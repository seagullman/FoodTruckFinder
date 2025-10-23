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
    
    private var accentColor: Color {
        guard let cuisine = foodTruck.cuisineType else { return .red }
        switch cuisine {
        case .mexican: return .orange
        case .pizza: return .red
        case .asian, .japanese: return .purple
        case .italian: return .green
        case .bbq: return .brown
        case .coffee: return .brown
        case .sandwiches: return .yellow
        case .american: return .blue
        }
    }
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                onTap()
            }
        }) {
            VStack(spacing: 0) {
                // Main marker circle
                ZStack {
                    // Outer glow
                    if isSelected {
                        Circle()
                            .fill(accentColor.opacity(0.2))
                            .frame(width: 56, height: 56)
                            .blur(radius: 8)
                    }
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? [accentColor, accentColor.opacity(0.8)] : [.white, Color(.systemGray6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isSelected ? 44 : 38, height: isSelected ? 44 : 38)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.white : accentColor.opacity(0.4), lineWidth: isSelected ? 3 : 2)
                        )
                        .shadow(color: .black.opacity(isSelected ? 0.25 : 0.15), radius: isSelected ? 12 : 8, x: 0, y: isSelected ? 6 : 4)
                    
                    // Icon or image
                    if let imageUrlString = foodTruck.imageUrl, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: isSelected ? 36 : 30, height: isSelected ? 36 : 30)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "fork.knife")
                                .font(.system(size: isSelected ? 18 : 15, weight: .semibold))
                                .foregroundColor(isSelected ? .white : accentColor)
                        }
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: isSelected ? 18 : 15, weight: .semibold))
                            .foregroundColor(isSelected ? .white : accentColor)
                    }
                }
                .scaleEffect(isPressed ? 0.92 : 1.0)
                
                // Pointer triangle
                Triangle()
                    .fill(isSelected ? accentColor : .white)
                    .frame(width: isSelected ? 18 : 15, height: isSelected ? 14 : 11)
                    .offset(y: -2)
                    .overlay(
                        Triangle()
                            .stroke(isSelected ? Color.white : accentColor.opacity(0.4), lineWidth: isSelected ? 2.5 : 1.5)
                            .offset(y: -2)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .scaleEffect(isPressed ? 0.92 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.12 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.68), value: isSelected)
        .animation(.easeInOut(duration: 0.08), value: isPressed)
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