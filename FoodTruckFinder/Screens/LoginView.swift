//
//  LoginView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        
        Text("Login View")
        Form {
            TextField("Email", text: $email)
            TextField("Password", text: $password)
                .textContentType(.password)
                .autocorrectionDisabled()
                .autocapitalization(.none)
            Button {
                Task { try await authViewModel.signIn(withEmail: email, password: password) }
            } label: {
                Text("Login")
            }
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
        }
    }
}

// MARK: AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        // TODO: update these requirements
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
