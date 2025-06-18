//
//  Stock.swift
//  StockTracker
//
//  Created by Nicolas Torrens on 6/18/25.
//

import Foundation
import SwiftData

@Model
class Stock {
    @Attribute(.unique) var symbol: String
    var name: String
    var price: Decimal?
    
    init(symbol: String, name: String, price: Decimal? = nil) {
        self.symbol = symbol
        self.name = name
        self.price = price
    }
}

public func fetchQuote(for symbol: String) async -> Decimal? {
    let apiKey = "d187kbhr01ql1b4maqigd187kbhr01ql1b4maqj0"
    let urlString = "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(apiKey)"
    
    guard let url = URL(string: urlString) else { return nil }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let priceNumber = json["c"] as? NSNumber {
            return Decimal(string: priceNumber.stringValue)  // ✅ Manual conversion to Decimal
        }
    } catch {
        print("Error fetching quote for \(symbol): \(error)")
    }
    
    return nil
}
