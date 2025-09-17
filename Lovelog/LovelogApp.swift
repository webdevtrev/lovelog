//
//  LovelogApp.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/4/25.
//

import SwiftUI
import Supabase

@main
struct LoveLogApp: App {
    // Store the selection across launches
    @AppStorage("selectedTheme") private var selectedThemeRaw = AppearanceOption.followSystem.rawValue
    @StateObject private var authStore = SupabaseAuthStore()
    private var selectedTheme: AppearanceOption {
        AppearanceOption(rawValue: selectedThemeRaw) ?? .followSystem
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // Apply globally. `preferredColorScheme` accepts `ColorScheme?`
                .preferredColorScheme(selectedTheme.colorScheme)
                .environmentObject(authStore)
                .onOpenURL { url in
                  authStore.handle(url)          // completes the OAuth flow
                }
        }
    }
}
