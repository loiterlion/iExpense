//
//  ContentView.swift
//  iExpense
//
//  Created by Bruce Wang on 2023/12/14.
//

import Observation
import SwiftUI

struct ExpenseItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.setValue(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                items = decodedItems
                return
            }
        }
        items = []
    }
}

struct ColoredText: ViewModifier {
    var amount: Double
    func body(content: Content) -> some View {
        if amount > 100 {
            content
                .foregroundColor(.red)
                .font(.headline)
        } else if amount > 10 {
            content
                .foregroundColor(.yellow)
                .font(.subheadline)
        } else {
            content
                .foregroundColor(.green)
                .font(.footnote)
        }
    }
}

extension View {
    func coloredText(amount: Double) -> some View {
        modifier(ColoredText(amount: amount))
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
        
    var body: some View {
        NavigationStack {
            List {
                Section("Person Items"){
                    ForEach(expenses.items.filter { $0.type == "Personal" }) { item in
                        HStack {
                            VStack(alignment: .leading, content: {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            })
                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                                .coloredText(amount: item.amount)
                        }
                    }
                    .onDelete { indexSet in
                        removeItemsForBusiness(at: indexSet, type: "Personal")
                    }
                }
                
                Section("Business Items"){
                    ForEach(expenses.items.filter { $0.type == "Business" }) { item in
                        HStack {
                            VStack(alignment: .leading, content: {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            })
                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                                .coloredText(amount: item.amount)
                        }
                    }
                    .onDelete { indexSet in
                        removeItemsForBusiness(at: indexSet, type: "Business")
                    }
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                NavigationLink(destination: AddView(expenses: expenses)) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    func removeItemsForBusiness(at offsets: IndexSet, type: String) {
        let filtedItems = expenses.items.filter { $0.type == type}
        let itmesToRemove: [ExpenseItem] = offsets.compactMap{ filtedItems[$0] }
        expenses.items.removeAll(where: itmesToRemove.contains(_:))
    }
}

#Preview {
    ContentView()
}
