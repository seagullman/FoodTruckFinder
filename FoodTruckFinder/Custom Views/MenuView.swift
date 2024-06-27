//
//  MenuView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/26/24.
//

import SwiftUI

struct MenuView: View {
    
    let menuCategories: [MenuCategory]
    
    var body: some View {
        ForEach(menuCategories) { category in
            MenuCategoryView(menuCategory: category)
        }
    }
}

#Preview {
    MenuView(
        menuCategories: [MenuCategory(category: "Appetizers",
                            items: [
                                MenuItem(
                                    name: "Cheese Sticks",
                                    description: "Lightly breaded and fried until golden brown. Served with ranch",
                                    price: 6.99,
                                    isVegetarian: true,
                                    isGlutenFree: false
                                )])])
}
