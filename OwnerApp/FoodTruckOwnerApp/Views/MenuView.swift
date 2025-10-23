//
//  MenuView.swift
//  FoodTruckOwnerApp
//

import SwiftUI

struct MenuView: View {
    
    @Environment(TruckStore.self) private var truckStore
    @State private var menuCategories: [MenuCategory] = []
    @State private var showingAddCategory = false
    @State private var editingCategory: MenuCategory?
    @State private var categoryToDelete: MenuCategory?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                if menuCategories.isEmpty {
                    EmptyMenuView()
                } else {
                    ForEach(Array(menuCategories.enumerated()), id: \.element.id) { index, category in
                        CategorySection(
                            category: category,
                            onEdit: { editingCategory = category },
                            onDelete: {
                                categoryToDelete = category
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCategory = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(categories: $menuCategories, truckStore: truckStore)
            }
            .sheet(item: $editingCategory) { category in
                EditCategoryView(
                    category: category,
                    categories: $menuCategories,
                    truckStore: truckStore
                )
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategory(category)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this category and all its items?")
            }
            .task {
                loadMenu()
            }
            .onChange(of: truckStore.truck?.menu) { _, newMenu in
                if let newMenu = newMenu {
                    menuCategories = newMenu
                }
            }
        }
    }
    
    private func loadMenu() {
        if let menu = truckStore.truck?.menu {
            menuCategories = menu
            print("✅ Loaded \(menu.count) menu categories")
        }
    }
    
    private func deleteCategory(_ category: MenuCategory) {
        menuCategories.removeAll { $0.id == category.id }
        Task {
            try? await truckStore.updateMenu(menuCategories)
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(item.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if item.isVegetarian {
                        Badge(text: "Vegetarian", color: .green)
                    }
                    if item.isGlutenFree {
                        Badge(text: "Gluten-Free", color: .blue)
                    }
                }
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", item.price))")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.red)
        }
        .padding(.vertical, 8)
    }
}

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.15)))
    }
}

struct EmptyMenuView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Menu Items")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Add your first menu category to get started")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Category Section

struct CategorySection: View {
    let category: MenuCategory
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        Section {
            if isExpanded {
                if category.items.isEmpty {
                    Text("No items yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(category.items, id: \.id) { item in
                        MenuItemRow(item: item)
                    }
                }
            }
        } header: {
            HStack {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack(spacing: 8) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text(category.category)
                            .font(.system(size: 16, weight: .bold))
                        
                        Text("(\(category.items.count))")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Add Category View

struct AddCategoryView: View {
    @Binding var categories: [MenuCategory]
    let truckStore: TruckStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var categoryName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Name") {
                    TextField("e.g., Tacos, Burgers, Drinks", text: $categoryName)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Text("You can add items to this category after creating it.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        addCategory()
                    }
                    .disabled(categoryName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func addCategory() {
        let newCategory = MenuCategory(category: categoryName, items: [])
        categories.append(newCategory)
        
        print("📝 Adding category: \(categoryName), total categories: \(categories.count)")
        
        Task {
            do {
                try await truckStore.updateMenu(categories)
                print("✅ Category saved successfully")
            } catch {
                print("❌ Failed to save category: \(error)")
            }
        }
        
        dismiss()
    }
}

// MARK: - Edit Category View

struct EditCategoryView: View {
    let category: MenuCategory
    @Binding var categories: [MenuCategory]
    let truckStore: TruckStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var categoryName: String
    @State private var items: [MenuItem]
    @State private var showingAddItem = false
    @State private var editingItem: MenuItem?
    
    init(category: MenuCategory, categories: Binding<[MenuCategory]>, truckStore: TruckStore) {
        self.category = category
        self._categories = categories
        self.truckStore = truckStore
        self._categoryName = State(initialValue: category.category)
        self._items = State(initialValue: category.items)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Name") {
                    TextField("Category name", text: $categoryName)
                        .autocorrectionDisabled()
                }
                
                Section {
                    ForEach(items, id: \.id) { item in
                        Button(action: { editingItem = item }) {
                            MenuItemRow(item: item)
                        }
                    }
                    .onDelete(perform: deleteItems)
                    
                    Button(action: { showingAddItem = true }) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Items (\(items.count))")
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(categoryName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddMenuItemView(items: $items)
            }
            .sheet(item: $editingItem) { item in
                EditMenuItemView(item: item, items: $items)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    private func saveChanges() {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = MenuCategory(category: categoryName, items: items)
            
            print("📝 Saving category: \(categoryName) with \(items.count) items")
            
            Task {
                do {
                    try await truckStore.updateMenu(categories)
                    print("✅ Category changes saved successfully")
                } catch {
                    print("❌ Failed to save category changes: \(error)")
                }
            }
        }
        dismiss()
    }
}

// MARK: - Add Menu Item View

struct AddMenuItemView: View {
    @Binding var items: [MenuItem]
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var priceText = ""
    @State private var isVegetarian = false
    @State private var isGlutenFree = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                    
                    HStack {
                        Text("$")
                        TextField("Price", text: $priceText)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Dietary Info") {
                    Toggle("Vegetarian", isOn: $isVegetarian)
                    Toggle("Gluten-Free", isOn: $isGlutenFree)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !description.isEmpty && Double(priceText) != nil
    }
    
    private func addItem() {
        guard let price = Double(priceText) else { return }
        
        let newItem = MenuItem(
            name: name,
            description: description,
            price: price,
            isVegetarian: isVegetarian,
            isGlutenFree: isGlutenFree
        )
        
        items.append(newItem)
        dismiss()
    }
}

// MARK: - Edit Menu Item View

struct EditMenuItemView: View {
    let item: MenuItem
    @Binding var items: [MenuItem]
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var priceText: String
    @State private var isVegetarian: Bool
    @State private var isGlutenFree: Bool
    
    init(item: MenuItem, items: Binding<[MenuItem]>) {
        self.item = item
        self._items = items
        self._name = State(initialValue: item.name)
        self._description = State(initialValue: item.description)
        self._priceText = State(initialValue: String(format: "%.2f", item.price))
        self._isVegetarian = State(initialValue: item.isVegetarian)
        self._isGlutenFree = State(initialValue: item.isGlutenFree)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                    
                    HStack {
                        Text("$")
                        TextField("Price", text: $priceText)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Dietary Info") {
                    Toggle("Vegetarian", isOn: $isVegetarian)
                    Toggle("Gluten-Free", isOn: $isGlutenFree)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !description.isEmpty && Double(priceText) != nil
    }
    
    private func saveChanges() {
        guard let price = Double(priceText),
              let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        items[index] = MenuItem(
            name: name,
            description: description,
            price: price,
            isVegetarian: isVegetarian,
            isGlutenFree: isGlutenFree
        )
        
        dismiss()
    }
}
