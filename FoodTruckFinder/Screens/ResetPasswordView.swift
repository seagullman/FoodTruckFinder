//
//  ResetPasswordView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/28/24.
//

import SwiftUI

struct ResetPasswordView: View {
    @State var email: String = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Image("food-truck-clipart")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .padding(.vertical, 32)
            
            InputView(text: $email, title: "Email Address", 
                      placeholder: "Enter the email associated with your account",
                      keyboardType: .emailAddress)
                .padding(.horizontal)
            
            
            Button(action: {
                Task { await authViewModel.resetPassword(withEmail: email) }
                dismiss()
            }, label: {
                HStack {
                    Text("SEND RESET LINK")
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
                    Image(systemName: "arrow.left")
                    Text("Back to Login")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                }
            })
        }
    }
}

// MARK: AuthenticationFormProtocol

extension ResetPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
    }
}

#Preview {
    ResetPasswordView()
}
