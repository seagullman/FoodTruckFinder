//
//  RegistrationView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/28/24.
//

import SwiftUI

struct RegistrationView: View {
    @State var email: String = ""
    @State var fullName: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack {
            Image("food-truck-clipart")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .padding(.vertical, 32)
            
            VStack(spacing: 24) {
                
                // email
                
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "name@example.com",
                          keyboardType: .emailAddress)
                .autocapitalization(.none)
                
                // full name
                
                InputView(text: $fullName,
                          title: "Full Name",
                          placeholder: "Enter your name")
                
                
                // password
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                
                // confirm password
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Comfirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: true)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemRed))
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                Task { try await authViewModel.createUser(withEmail: email, password: password, fullName: fullName)}
            }, label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48) // TODO: fix UISCreen.main deprecation
            })
            .disabled(!formIsValid)
            .background(Color(.systemBlue))
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }, label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                }
            })
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
