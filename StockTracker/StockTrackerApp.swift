//
//  StockTrackerApp.swift
//  StockTracker
//
//  Created by Nicolas Torrens on 6/18/25.
//

import SwiftUI

@main
struct StockTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Stock.self)
    }
}
