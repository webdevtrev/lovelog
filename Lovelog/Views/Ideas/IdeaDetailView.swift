//
//  IdeaDetailView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

struct IdeaDetailView: View {
    let idea: DateIdea
    let user: User?
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 8) {
                    ColorDot(color: user?.preferredColor ?? .gray)
                    Text(idea.title)
                        .font(.title3.weight(.semibold))
                }
                if let user {
                    TagPill(text: "By \(user.name)", color: user.preferredColor)
                }
                if let date = idea.scheduledDate {
                    Label(date.formatted(date: .complete, time: .shortened), systemImage: "calendar")
                } else {
                    Label("Not scheduled", systemImage: "calendar.slash")
                        .foregroundStyle(.secondary)
                }
            }
            
            if !idea.notes.isEmpty {
                Section("Notes") {
                    Text(idea.notes)
                }
            }
        }
        .navigationTitle("Idea Details")
    }
}
