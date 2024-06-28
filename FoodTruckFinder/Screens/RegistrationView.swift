//
//  RegistrationView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/28/24.
//

import SwiftUI

struct RegistrationView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var fullName: String = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        
        Text("Login View")
        Form {
            TextField("Email", text: $email)
            TextField("Password", text: $password)
            TextField("Full Name", text: $fullName)
                .textContentType(.password)
                .autocorrectionDisabled()
                .autocapitalization(.none)
            Button {
                Task { try await authViewModel.createUser(withEmail: email, password: password, fullName: fullName) }
            } label: {
                Text("Sign Up")
            }
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
        }
    }
}

// MARK: AuthenticationFormProtocol

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        // TODO: update these requirements
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && !fullName.isEmpty
        // TODO: add && confirmPassword == password
    }
}

#Preview {
    RegistrationView()
}
