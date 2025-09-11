//
//  TagPill.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

struct TagPill: View {
    var text: String
    var color: Color
    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .overlay(
                Capsule().stroke(color.opacity(0.6), lineWidth: 1)
            )
            .foregroundStyle(.primary)
    }
}
#Preview{
    TagPill(text: "Trevor", color: .blue)
}
