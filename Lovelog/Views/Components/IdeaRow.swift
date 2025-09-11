//
//  IdeaRow.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

struct IdeaRow: View {
    let idea: DateIdea
    let user: User?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(idea.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                if let date = idea.scheduledDate, date > .now {
                    Label(relativeTimeString(to: date), systemImage: "calendar")
                        .font(.caption)
                        .padding(.top, 2)
                }
            }
            Spacer(minLength: 4)
            
            if let user {
                TagPill(text: user.name, color: user.preferredColor)
            }
        }
        .padding(.vertical, 6)
    }
}
