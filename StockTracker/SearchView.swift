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
    
    var body: some View {
        VStack {
            // Search bar
            TextField("Search stocks...", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: query) { _ in
                    Task {
                        await searchStocks()
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
                        let newStock = Stock(symbol: result.symbol, name: result.description)
                        modelContext.insert(newStock)
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
