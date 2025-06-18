//
//  ContentView.swift
//  StockTracker
//
//  Created by Nicolas Torrens on 6/18/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            WatchListView()
                .tabItem {
                    Label("Watchlist", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
