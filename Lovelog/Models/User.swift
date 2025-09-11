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
