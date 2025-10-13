//
//  PredefinedColorPicker.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/19/25.
//


import SwiftUI

struct PredefinedColorPicker: View {
    @Binding var selectedColor: Color
    
    let options: [Color] = [.red, .blue, .green, .orange, .pink]

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ForEach(options, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                        .accessibilityLabel(Text("\(color.description)"))
                }
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedColor: Color = .red
    VStack{
        PredefinedColorPicker(selectedColor: $selectedColor)
    }
    
    
}
