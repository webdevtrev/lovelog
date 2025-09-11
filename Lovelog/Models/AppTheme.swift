//
//  AppTheme.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/11/25.
//


import SwiftUI

enum AppearanceOption: String, CaseIterable, Identifiable {
    case followSystem, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .followSystem: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    /// Optional on purpose: `nil` means “follow system”
    var colorScheme: ColorScheme? {
        switch self {
        case .followSystem: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
