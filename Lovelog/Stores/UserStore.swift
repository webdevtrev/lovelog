//
//  UserStore.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/18/25.
//
import SwiftUI
import Supabase
typealias SupaUser = Auth.User

@MainActor
func createUserIfNeeded(authUser: SupaUser, name: String?) async {
    do {
        let id = authUser.id
        
        // Check if row exists
        let existing: [UserRow] = try await supabase
            .from("users")
            .select()
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value

        guard existing.isEmpty else { return }
        
        let newUser = NewUser(
            id: id,
            name: name == nil ? "" : name,
            onboarded: false,
            archived: false
        )
        
        try await supabase
            .from("users")
            .insert(newUser)
            .execute()
        
    } catch {
        print("createUserIfNeeded error:", error)
    }
}
@MainActor
func saveProfileAndFinish(
    name: String,
    handle: String,
    selectedTheme: ThemeColor?
) async throws {
    guard let theme = selectedTheme else { return }

    let session = try await supabase.auth.session
    let userId: UUID = session.user.id
    struct UserUpdate: Encodable {
        let color: String
        let name: String
        let handle: String
        let onboarded: Bool
    }
    let payload = UserUpdate(
        color: theme.rawValue,
        name: name,
        handle: handle,
        onboarded: true
    )
    try await supabase
        .from("users")
        .update(payload)
        .eq("id", value: userId)
        .execute()
}

func loadThemeColor(for userId: UUID) async throws -> Color {
    let rows: [UserRow] = try await supabase
        .from("users")
        .select("id, color")
        .eq("id", value: userId)
        .limit(1)
        .execute()
        .value

    let key = rows.first?.color ?? ThemeColor.red.rawValue
    let theme = ThemeColor(rawValue: key) ?? .red
    return theme.color
}

@MainActor
func searchUsers(by query: String) async throws -> [UserRow] {
    let filter = "name.ilike.%\(query)%,handle.ilike.%\(query)%"

    let result: [UserRow] = try await supabase
        .from("users")
        .select("*")
        .or(filter)
        .limit(20)
        .execute()
        .value

    return result
}
