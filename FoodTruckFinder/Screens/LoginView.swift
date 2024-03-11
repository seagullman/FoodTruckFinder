//
//  LoginView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        Form {
            TextField("Email", text: $email)
            TextField("Password", text: $password)
                .textContentType(.password)
            Button {
                Task {
                    let user = await FTFAuthManager.shared.loginUser(email: email, password: password)
//                    if let user {
//                        print("***** USER LOGGED IN")
//                    }
                }
            } label: {
                Text("Login")
            }

        }
    }
}

#Preview {
    LoginView(email: "test@email.com", password: "12345")
}
