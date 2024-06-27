//
//  MenuCategoryView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/26/24.
//

import SwiftUI

struct MenuCategoryView: View {
    
    let menuCategory: MenuCategory
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(menuCategory.category)
                .font(.title.bold())
            
            ForEach(menuCategory.items) { item in
                MenuItemView(menuItem: item)
            }
        }
    }
}

#Preview {
    MenuCategoryView(menuCategory: MenuCategory(category: "Burgers", items: [
        MenuItem(
            name: "Big Mac",
            description: "Two 100% pure all beef patties and Big Mac® sauce sandwiched between a sesame seed bun.",
            price: 5.99,
            isVegetarian: false,
            isGlutenFree: false
        )
    ]))
}
