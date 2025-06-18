//
//  SearchView.swift
//  StockTracker
//
//  Created by Nicolas Torrens on 6/18/25.
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var query: String = ""
    @State private var results: [SearchResult] = []
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            // Search bar
            TextField("Search stocks...", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($isTextFieldFocused)
                .onChange(of: query) { _ in
                    Task {
                        await searchStocks()
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isTextFieldFocused = false // Dismiss keyboard
                        }
                    }
                }

            // Search results
            List(results) { result in
                HStack {
                    VStack(alignment: .leading) {
                        Text(result.symbol).bold()
                        Text(result.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button("Add") {
                        // Check for duplicates manually
                        if !stockExists(symbol: result.symbol) {
                            let newStock = Stock(symbol: result.symbol, name: result.description, price: nil)
                            modelContext.insert(newStock)
                            try? modelContext.save()
                        } else {
                            print("Stock already exists")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Search Stocks")
    }
    
    // Async function to search
    func searchStocks() async {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        let apiKey = "d187kbhr01ql1b4maqigd187kbhr01ql1b4maqj0"
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://finnhub.io/api/v1/search?q=\(queryEncoded)&exchange=US&token=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
            results = decoded.result
        } catch {
            print("Error fetching search results: \(error)")
        }
    }
    
    func stockExists(symbol: String) -> Bool {
        // SwiftData way of manually checking for duplicates
        return (try? modelContext.fetch(FetchDescriptor<Stock>(predicate: #Predicate { $0.symbol == symbol })).isEmpty == false) ?? false
    }
}

struct SearchResult: Identifiable, Decodable {
    var id: String { symbol }
    let description: String
    let symbol: String
}

struct SearchResponse: Decodable {
    let result: [SearchResult]
}

#Preview {
    SearchView()
}
