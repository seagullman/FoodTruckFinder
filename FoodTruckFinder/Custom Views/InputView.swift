//
//  InputView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/28/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    
    let title: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .keyboardType(keyboardType)
            }
            
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), 
              title: "Email Address",
              placeholder: "name@example.com",
              keyboardType: .emailAddress)
}
