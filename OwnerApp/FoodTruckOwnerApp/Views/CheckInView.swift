//
//  CheckInView.swift
//  FoodTruckOwnerApp
//

import SwiftUI
import MapKit
import CoreLocation

struct CheckInView: View {
    
    @Environment(TruckStore.self) private var truckStore
    @State private var locationManager = LocationManager()
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedTime = Date().addingTimeInterval(4 * 3600)
    @State private var showingTimePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map
                Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: [MapPin()]) { pin in
                    MapAnnotation(coordinate: mapRegion.center) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .shadow(radius: 4)
                    }
                }
                .ignoresSafeArea()
                
                // Bottom card
                VStack {
                    Spacer()
                    
                    CheckInCard(
                        isCheckedIn: truckStore.isCheckedIn,
                        selectedTime: $selectedTime,
                        showingTimePicker: $showingTimePicker,
                        onCheckIn: handleCheckIn,
                        onCheckOut: handleCheckOut
                    )
                    .padding(16)
                }
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if let location = locationManager.lastLocation {
                    mapRegion.center = location.coordinate
                }
            }
            .onChange(of: locationManager.lastLocation) { newLocation in
                if let location = newLocation {
                    withAnimation {
                        mapRegion.center = location.coordinate
                    }
                }
            }
        }
    }
    
    private func handleCheckIn() {
        Task {
            do {
                let location = CLLocation(
                    latitude: mapRegion.center.latitude,
                    longitude: mapRegion.center.longitude
                )
                
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let timeString = formatter.string(from: selectedTime)
                
                try await truckStore.checkIn(
                    at: location,
                    until: timeString,
                    description: "Current Location"
                )
            } catch {
                print("❌ Check-in failed: \(error)")
            }
        }
    }
    
    private func handleCheckOut() {
        Task {
            do {
                try await truckStore.checkOut()
            } catch {
                print("❌ Check-out failed: \(error)")
            }
        }
    }
}

struct CheckInCard: View {
    let isCheckedIn: Bool
    @Binding var selectedTime: Date
    @Binding var showingTimePicker: Bool
    let onCheckIn: () -> Void
    let onCheckOut: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
            
            if isCheckedIn {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        
                        Text("You're Open!")
                            .font(.system(size: 22, weight: .bold))
                        
                        Spacer()
                    }
                    
                    Text("Customers can now find you on the map")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: onCheckOut) {
                        Text("Check Out")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.red)
                            )
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Text("Set Your Hours")
                        .font(.system(size: 22, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: { showingTimePicker.toggle() }) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.red)
                            
                            Text("Open until")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(selectedTime, style: .time)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.systemGray6))
                        )
                    }
                    
                    if showingTimePicker {
                        DatePicker("Close Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    
                    Button(action: onCheckIn) {
                        HStack(spacing: 8) {
                            Text("Check In")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.red)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
    }
}

struct MapPin: Identifiable {
    let id = UUID()
}
