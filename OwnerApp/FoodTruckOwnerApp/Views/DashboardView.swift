//
//  DashboardView.swift
//  FoodTruckOwnerApp
//

import SwiftUI

struct DashboardView: View {
    
    @Environment(TruckStore.self) private var truckStore
    @Environment(OwnerAuthStore.self) private var authStore
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status card
                    StatusCard(isCheckedIn: truckStore.isCheckedIn)
                    
                    // Quick actions
                    QuickActionsGrid(selectedTab: $selectedTab)
                    
                    // Stats
                    StatsSection()
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await authStore.signOut() } }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

struct StatusCard: View {
    let isCheckedIn: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isCheckedIn ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                        
                        Text(isCheckedIn ? "Open" : "Closed")
                            .font(.system(size: 24, weight: .bold))
                    }
                }
                
                Spacer()
                
                Image(systemName: isCheckedIn ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(isCheckedIn ? .green : .gray)
            }
            
            if isCheckedIn {
                Divider()
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                    Text("Currently serving customers")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct QuickActionsGrid: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                QuickActionButton(icon: "location.fill", title: "Check In", color: .red) {
                    selectedTab = 1
                }
                QuickActionButton(icon: "list.bullet", title: "Update Menu", color: .orange) {
                    selectedTab = 2
                }
                QuickActionButton(icon: "photo", title: "Upload Photo", color: .blue) {
                    selectedTab = 3
                }
                QuickActionButton(icon: "chart.bar.fill", title: "Analytics", color: .purple) {
                    // Future feature
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
    }
}

struct StatsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Stats")
                .font(.system(size: 20, weight: .bold))
            
            HStack(spacing: 16) {
                StatCard(value: "0", label: "Views", icon: "eye.fill", color: .blue)
                StatCard(value: "0", label: "Favorites", icon: "heart.fill", color: .red)
            }
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}
