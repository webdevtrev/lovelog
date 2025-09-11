//
//  ColorDot.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

struct ColorDot: View {
    var color: Color
    var body: some View {
        Circle()
            .fill(color.gradient)
            .frame(width: 14, height: 14)
            .overlay(
                Circle().stroke(.quaternary, lineWidth: 1)
            )
    }
}

#Preview{
    ColorDot(color: .blue)
}
