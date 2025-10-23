//
//  ConfirmCodeView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 1/21/25.
//

import SwiftUI

struct ConfirmCodeView: View {
    @Environment(AuthStore.self) var authStore: AuthStore
    @State private var code = ""
    
    let email: String
    
    var body: some View {
        VStack {
            Text("One time code:")
            TextField("ONe time code", text: $code)
            Button {
                print("🫣 user: \(authStore.currentUser?.email)")
                Task { try await authStore.confirmSignUp(email: email, confirmationCode: code) }
            } label: {
                Text("CONFIRM")
            }

        }
    }
}

#Preview {
    ConfirmCodeView(email: "test@email.com")
        .environment(AuthStore())
}
