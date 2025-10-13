//
//  User.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/5/25.
//
import SwiftUI

struct User: Identifiable, Hashable {
    let id: UUID
    var name: String
    /// User-chosen UI color preference
    var preferredColor: Color
}

struct UserRow: Codable, Equatable, Identifiable {
    let id: UUID
    let handle: String?
    let name: String?
    let created_at: Date?
    let color: String?
    let couple_id: UUID?
    let onboarded: Bool?
    let archived: Bool?
}

struct NewUser: Codable {
    let id: UUID
    let name: String?
    let onboarded: Bool
    let archived: Bool
}
