//
//  LoginView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI

struct UnauthenticatedNavigationStack: View {
    
    @State private var routes: [UnauthenticatedRoute] = []
    
    var body: some View {
        NavigationStack(path: $routes) {
            LoginView()
                .navigationDestination(for: UnauthenticatedRoute.self) { route in
                    route.destination
                }
        }.environment(\.navigate, NavigateAction(action: { route in
            if case let .unauthenticated(unauthenticatedRoute) = route {
                routes.append(unauthenticatedRoute)
            }
        }))
    }
}

struct LoginView: View {

    @Environment(\.navigate) private var navigate
    @Environment(AuthStore.self) var authViewModel: AuthStore
    
    @State var email: String = ""
    @State var password: String = ""
    
    
    var body: some View {
        VStack {
            // image
            Image("food-truck-clipart")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .padding(.vertical, 32)
            
            // form fields
            
            VStack(spacing: 24) {
                // email
                
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "name@example.com",
                          keyboardType: .emailAddress)
                .autocapitalization(.none)
                
                // password
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        ResetPasswordView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Forgot Password?")
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal)
            
            // sign in buttton
            
            Button(action: {
                Task { try await authViewModel.signIn(withEmail: email, password: password) }
            }, label: {
                HStack {
                    Text("SIGN IN")
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
            
            // sign up button
            
            Button {
                navigate(.unauthenticated(.registration))
            } label: {
                HStack(spacing: 3) {
                    Text("Don't have an account?")
                    Text("Sign up")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                }
            }
        }
        
//        .task {
//            await authViewModel.signOut()
//        }
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
        .environment(AuthStore())
}
