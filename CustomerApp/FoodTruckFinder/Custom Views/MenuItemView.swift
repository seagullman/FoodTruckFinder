//
//  MenuItemView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/26/24.
//

import SwiftUI

struct MenuItemView: View {
    
    let menuItem: MenuItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(menuItem.name)
                .font(.headline.bold())
            Text(menuItem.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(menuItem.price, format: .currency(code: String(Locale.current.currency?.identifier ?? "USD")))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.secondary, lineWidth: 0.2)
        }
    }
}

#Preview {
    MenuItemView(menuItem:
                    MenuItem(
                        name: "Cheese Sticks",
                        description: "Lin brown. Served with ranch",
                        price: 6.99,
                        isVegetarian: true,
                        isGlutenFree: false
                    )
    )
}
