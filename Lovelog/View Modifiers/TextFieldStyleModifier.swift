//
//  TextFieldStyleModifier.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/19/25.
//


import SwiftUI

struct TextFieldStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
            )
    }
}

extension View {
    func appTextFieldStyle() -> some View {
        self.modifier(TextFieldStyleModifier())
    }
}
