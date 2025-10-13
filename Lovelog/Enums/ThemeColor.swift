import SwiftUI

enum ThemeColor: String, Codable, CaseIterable, Hashable {
    case red, blue, green, orange

    var color: Color {
        switch self {
        case .red:    return .red
        case .blue:   return .blue
        case .green:  return .green
        case .orange: return .orange
        }
    }

    var displayName: String {
        switch self {
        case .red: return "Red"
        case .blue: return "Blue"
        case .green: return "Green"
        case .orange: return "Orange"
        }
    }
}
