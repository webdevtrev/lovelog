//
//  UpcomingIdeaRow.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

struct UpcomingIdeaRow: View {
    let idea: DateIdea
    let user: User?
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(idea.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                if let date = idea.scheduledDate {
                    HStack {
                        Text(relativeTimeString(to: date))
                            .font(.subheadline.weight(.semibold))
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            Spacer()
            
            if let user {
                TagPill(text: user.name, color: user.preferredColor)
            }
        }
        .padding(.vertical, 6)
    }
}
