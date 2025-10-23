//
//  ProfileView.swift
//  FoodTruckOwnerApp
//

import SwiftUI
import Amplify

struct ProfileView: View {
    
    @Environment(TruckStore.self) private var truckStore
    @Environment(OwnerAuthStore.self) private var authStore
    
    @State private var truckName = "My Food Truck"
    @State private var description = "Delicious food on wheels"
    @State private var cuisineType = "american"
    @State private var websiteUrl = ""
    @State private var showingImagePicker = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Logo section
                Section {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "truck.box.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                            }
                            
                            Button("Upload Logo") {
                                showingImagePicker = true
                            }
                            .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                } header: {
                    Text("Logo")
                }
                
                // Basic info
                Section {
                    TextField("Truck Name", text: $truckName)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Cuisine Type", selection: $cuisineType) {
                        Text("American").tag("american")
                        Text("Mexican").tag("mexican")
                        Text("Italian").tag("italian")
                        Text("Asian").tag("asian")
                        Text("Japanese").tag("japanese")
                        Text("BBQ").tag("bbq")
                        Text("Pizza").tag("pizza")
                        Text("Coffee").tag("coffee")
                    }
                    
                    TextField("Website (optional)", text: $websiteUrl)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                } header: {
                    Text("Basic Information")
                }
                
                // Account section
                Section {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authStore.currentUser?.username ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { Task { await authStore.signOut() } }) {
                        HStack {
                            Text("Sign Out")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("Account")
                }
                
                // Save button
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .tint(.red)
                            } else {
                                Text("Save Changes")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(.red)
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    private func saveProfile() {
        isSaving = true
        Task {
            do {
                try await truckStore.updateProfile(
                    name: truckName,
                    description: description,
                    cuisineType: cuisineType,
                    websiteUrl: websiteUrl.isEmpty ? nil : websiteUrl
                )
                print("✅ Profile saved")
            } catch {
                print("❌ Failed to save: \(error)")
            }
            isSaving = false
        }
    }
}
