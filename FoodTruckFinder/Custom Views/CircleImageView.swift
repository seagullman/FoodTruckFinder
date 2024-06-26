//
//  CircleAsyncImageView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/10/24.
//

import SwiftUI

struct CircleAsyncImageView: View {
    
    let url: URL
    var borderColor: Color?
    var borderLineWidth: CGFloat?
    var shadow: CGFloat?
    var loadingIndicatorSize: CGSize
    
    init(url: URL, 
         loadingIndicatorSize: CGSize,
         borderColor: Color? = nil,
         borderLineWidth: CGFloat? = nil,
         shadow: CGFloat? = nil
    ) {
        self.url = url
        self.loadingIndicatorSize = loadingIndicatorSize
        self.borderColor = borderColor
        self.borderLineWidth = borderLineWidth
        self.shadow = shadow
    }
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(.circle)
                .shadow(radius: shadow ?? 0)
                .overlay(Circle().stroke(borderColor ?? .white, lineWidth: borderLineWidth ?? 0))
        } placeholder: {
            ProgressView()
                .frame(width: loadingIndicatorSize.width, height: loadingIndicatorSize.height) // TODO: make these flexible
        }
    }
}

#Preview {
    CircleAsyncImageView(url: URL(string: "www.exampleImageUrl.com")!, loadingIndicatorSize: CGSize(width: 75, height: 75))
}
