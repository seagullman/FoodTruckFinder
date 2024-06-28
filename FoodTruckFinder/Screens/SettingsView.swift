//
//  SettingsView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/12/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button {
            authViewModel.signOut()
        } label: {
            Text("Sign out")
                .font(.title)
        }

    }
}

#Preview {
    SettingsView()
}
