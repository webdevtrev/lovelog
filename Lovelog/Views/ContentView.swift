//
//  ContentView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("This is Home")
                .tabItem {
                    Label("Explore", systemImage: "sparkles")
                }

            IdeasView()
                .tabItem {
                    Label("Ideas", systemImage: "heart.fill")
                }

            Text("This is Profile")
                .tabItem {
                    Label("Dates", systemImage: "person.2.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
