//
//  Couple.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/24/25.
//
import SwiftUI

struct CoupleRow: Codable {
    let id: UUID
    let invited_id: UUID
    let inviter_id: UUID
    let accepted: Bool
}
