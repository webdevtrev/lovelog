//
//  IdeasViewModel.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

@Observable
final class IdeasViewModel {
    var users: [User] = []
    var ideas: [DateIdea] = []
    
    init() {
        // Mock users with color preferences (as if set in user settings)
        let me = User(id: UUID(), name: "You",  preferredColor: .blue)
        let partner = User(id: UUID(), name: "Rashmi", preferredColor: .pink)
        users = [me, partner]
        
        // Helper for dates
        func daysFromNow(_ days: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: days, to: .now)!
        }
        
        // Mock ideas
        ideas = [
            DateIdea(id: UUID(),
                     title: "Columbus Nepali Restraunt",
                     notes: "Try some authentic Nepali momo",
                     createdByUserID: partner.id,
                     scheduledDate: daysFromNow(3),
                     isCopied: false,
                     archived: false,
                     completed: false),
            DateIdea(id: UUID(),
                     title: "Skydiving",
                     notes: "for the thrill seekers",
                     createdByUserID: partner.id,
                     scheduledDate: nil,
                     isCopied: false,
                     archived: false,
                     completed: false),
            DateIdea(id: UUID(),
                     title: "Drive in movie theater",
                     notes: "Big movie screen with a a nastolgic feel",
                     createdByUserID: me.id,
                     scheduledDate: nil,
                     isCopied: false,
                     archived: false,
                     completed: false),
            DateIdea(id: UUID(),
                     title: "Cincinnati Art Musuem",
                     notes: "kljdkasjdka sj d lajd alkjdaldj adjlk",
                     createdByUserID: me.id,
                     scheduledDate: daysFromNow(10),
                     isCopied: false,
                     archived: false,
                     completed: false),
        ]
    }

    
    func delete(_ idea: DateIdea) {
        ideas.removeAll { $0.id == idea.id }
    }
    func complete(_ idea: DateIdea) {
        if let index = ideas.firstIndex(where: { $0.id == idea.id }) {
            ideas[index].title = "New Title"
        }
    }
    // MARK: Derived Collections
    
    var userByID: [UUID: User] {
        Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
    }
    
    var upcomingIdeas: [DateIdea] {
        ideas
            .compactMap { idea in
                if let d = idea.scheduledDate, d > .now { return idea }
                return nil
            }
            .sorted { ($0.scheduledDate ?? .distantFuture) < ($1.scheduledDate ?? .distantFuture) }
    }
    
    var currentIdeas: [DateIdea] {
        ideas.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
}
