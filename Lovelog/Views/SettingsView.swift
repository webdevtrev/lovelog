//
//  SettingsView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/4/25.
//
import SwiftUI


struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw = AppearanceOption.followSystem.rawValue



  var body: some View {
    Form {
        Section("Appearance") {
                            Picker("Appearance", selection: $selectedThemeRaw) {
                                ForEach(AppearanceOption.allCases) { theme in
                                    Text(theme.label).tag(theme.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
    }
  }
}
#Preview {
    SettingsView()
}
