//
//  SettingsView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/12/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                LoginView()
            } label: {
                Text("Sign In")
            }

            VStack {
                Text("Settings View")
                
                if FTFAuthManager.shared.authState == .authenticated {
                    Button {
                        Task {
                            do {
                                 try FTFAuthManager.shared.signOut()
                            } catch {
                                print("***** Error signing user out")
                            }
                        }
                    } label: {
                        Text("Sign Out")
                    }
                } else {
                    Button("Sign In") {
                        LoginView()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
