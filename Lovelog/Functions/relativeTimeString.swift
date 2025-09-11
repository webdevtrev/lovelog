//
//  relativeTimeString.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

func relativeTimeString(to futureDate: Date) -> String {
    let fmt = RelativeDateTimeFormatter()
    fmt.unitsStyle = .full
    return fmt.localizedString(for: futureDate, relativeTo: .now) // e.g., "in 3 days"
}
