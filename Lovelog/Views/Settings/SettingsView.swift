//
//  SettingsView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/4/25.
//
import SwiftUI


struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw = AppearanceOption.followSystem.rawValue
    @EnvironmentObject private var authStore: SupabaseAuthStore



  var body: some View {
    Form {
        Section("Appearance") {
            Picker("Appearance", selection: $selectedThemeRaw) {
                ForEach(AppearanceOption.allCases) { theme in
                    Text(theme.label).tag(theme.rawValue)
                }
            }
            .pickerStyle(.segmented)
            Button(role: .destructive, action: test){
                Text("Test")
            }
            Button("Sign Out") {
              Task {
                  await authStore.signOut()
              }
            }
            .buttonStyle(.borderedProminent)
        }
    }
  }
}
#Preview {
    SettingsView()
}
