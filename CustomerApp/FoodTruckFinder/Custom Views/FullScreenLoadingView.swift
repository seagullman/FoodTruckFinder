//
//  FullScreenLoadingView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/11/24.
//

import SwiftUI

struct FullScreenLoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .controlSize(.large)
    }
}

#Preview {
    FullScreenLoadingView()
}
