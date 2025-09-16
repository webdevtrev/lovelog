//
//  CreateIdeaView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/4/25.
//
import SwiftUI

struct CreateIdeaView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
            Text("Create Idea")
                .font(.title2.weight(.semibold))
            Text("Placeholder screen — wire up your form here.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.background)
        .navigationTitle("New Idea")
    }
}

#Preview{
    CreateIdeaView()
}
