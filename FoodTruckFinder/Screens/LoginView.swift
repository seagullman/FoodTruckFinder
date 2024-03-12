//
//  LoginView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    @State var viewModel = ViewModel()
    
    var body: some View {
        Form {
            TextField("Email", text: $viewModel.email)
            TextField("Password", text: $viewModel.password)
                .textContentType(.password)
                .autocorrectionDisabled()
                .autocapitalization(.none)
            Button {
                Task { await viewModel.login(username: viewModel.email, password: viewModel.password) }
            } label: {
                Text("Login")
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
    }
}

#Preview {
    LoginView()
}
