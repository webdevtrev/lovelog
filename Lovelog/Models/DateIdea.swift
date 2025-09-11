//
//  DateIdea.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

struct DateIdea: Identifiable, Hashable {
    let id: UUID
    var title: String
    var notes: String
    var createdByUserID: UUID
    /// When scheduled, this idea appears under "Upcoming Dates"
    var scheduledDate: Date?
    var location: String?
    var minCost: Double?
    var maxCost: Double?
    var isPublished: Bool?
    let isCopied: Bool
    var archived: Bool
    var completed: Bool
    
    mutating func delete(){
        archived = true
    }
}
