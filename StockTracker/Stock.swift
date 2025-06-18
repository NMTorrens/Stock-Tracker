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
    
    init(symbol: String, name: String) {
        self.symbol = symbol
        self.name = name
    }
}
