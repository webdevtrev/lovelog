//
//  LovelogApp.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/4/25.
//

import SwiftUI

@main
struct LoveLogApp: App {
    // Store the selection across launches
    @AppStorage("selectedTheme") private var selectedThemeRaw = AppearanceOption.followSystem.rawValue
    @StateObject private var session = AppSession()
    private var selectedTheme: AppearanceOption {
        AppearanceOption(rawValue: selectedThemeRaw) ?? .followSystem
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Apply globally. `preferredColorScheme` accepts `ColorScheme?`
                .preferredColorScheme(selectedTheme.colorScheme)
                .environmentObject(session)
        }
    }
}
