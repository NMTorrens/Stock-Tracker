//
//  WatchListView.swift
//  StockTracker
//
//  Created by Nicolas Torrens on 6/18/25.
//

import SwiftData
import SwiftUI

struct WatchListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\Stock.symbol)]) var stocks: [Stock]
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(stocks) { stock in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stock.symbol).bold()
                            Text(stock.name)
                        }
                        
                        Spacer()
                        
                        if let price = stock.price {
                            Text("\(price, format: .currency(code: "USD"))")
                        } else {
                            Text("Loading...")
                        }
                    }
                }
                
                .onDelete(perform: deleteStock)
            }
            .refreshable {
                await refreshPrices()
            }
            .onAppear {
                Task {
                    await refreshPrices()
                }
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }
    
    func deleteStock(at offsets: IndexSet) {
        for offset in offsets {
            let stock = stocks[offset]
            
            modelContext.delete(stock)
        }
    }
    
    func refreshPrices() async {
        for stock in stocks {
            if let newPrice = await fetchQuote(for: stock.symbol) {
                stock.price = newPrice
            }
        }
        try? modelContext.save()
    }
}



#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Stock.self, configurations: config)

        let context = container.mainContext

        let exampleStock1 = Stock(symbol: "MSFT", name: "Microsoft")
        let exampleStock2 = Stock(symbol: "AAPL", name: "Apple")

        context.insert(exampleStock1)
        context.insert(exampleStock2)

        return WatchListView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
