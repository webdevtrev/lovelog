// CouplesRepository.swift
import Foundation
import Supabase

public struct CoupleWithUsers: Codable, Equatable, Identifiable {
  public let id: UUID
  public let inviter_id: UUID
  public let invited_id: UUID
  public let accepted: Bool?       // adapt if your column is named differently
  public let created_at: Date?
  let inviter: UserRow      // embedded via FK -> users
  let invited: UserRow      // embedded via FK -> users
}
public struct CoupleInsert: Encodable {
    let inviter_id: UUID
    let invited_id: UUID
    let accepted: Bool
}
// MARK: - Repository
public final class CouplesRepository {
  private let supabase: SupabaseClient

  // FK names you shared
  private let inviterFK = "couples_created_by_fkey"    // couples.inviter_id -> users.id
  private let invitedFK = "couples_invited_user_fkey"  // couples.invited_id -> users.id

  // Only the columns your UserRow needs
  private var userCols: String {
    "id, handle, name, created_at, color, couple_id, onboarded, archived"
  }

  // Couple + embedded users (explicit list keeps payload lean)
  private var selectClause: String {
    """
    id, inviter_id, invited_id, accepted, created_at,
    inviter:users!\(inviterFK) ( \(userCols) ),
    invited:users!\(invitedFK) ( \(userCols) )
    """
  }

  public init(supabase: SupabaseClient) {
    self.supabase = supabase
  }

  /// Couples involving the signed-in user (both directions), with inviter/invited user rows embedded.
  public func fetchMyCouples() async throws -> [CoupleWithUsers] {
    let session = try await supabase.auth.session
    return try await fetchCouples(involving: session.user.id)
  }

  /// Couples involving the given user id.
  public func fetchCouples(involving userId: UUID) async throws -> [CoupleWithUsers] {
    try await supabase
      .from("couples")
      .select(selectClause)
      .or("inviter_id.eq.\(userId.uuidString),invited_id.eq.\(userId.uuidString)")
      .order("created_at", ascending: false)
      .execute()
      .value
  }

  /// (Optional) Only incoming requests for this user (you can tweak the `accepted` filter as needed).
    public func fetchIncomingRequests(for userId: UUID, onlyPending: Bool = true) async throws -> [CoupleWithUsers] {
      var query = supabase
        .from("couples")
        .select(selectClause)
        .eq("invited_id", value: userId)

      if onlyPending { query = query.eq("accepted", value: false) }

      return try await query
        .order("created_at", ascending: false)
        .execute()
        .value
    }
    public func fetchOutgoingRequests(for userId: UUID, onlyPending: Bool = true) async throws -> [CoupleWithUsers] {
      var query = supabase
        .from("couples")
        .select(selectClause)
        .eq("inviter_id", value: userId)

      if onlyPending { query = query.eq("accepted", value: false) }

      return try await query
        .order("created_at", ascending: false)
        .execute()
        .value
    }
    func acceptInvite(coupleID: UUID) async throws -> CoupleRow {
      // The RPC returns a single couples row
      let accepted: CoupleRow = try await supabase
        .rpc("accept_couple_invite", params: ["p_couple_id": coupleID])
        .execute()
        .value
      return accepted
    }
    func rejectInvite(coupleID: UUID) async throws -> Void {
        try await supabase
            .from("couples")
            .delete()
            .eq("id", value: coupleID)
            .execute()
    }
    func inviteUser(inviter: UUID, invited: UUID) async throws -> CoupleWithUsers {
        // Insert payload (no `id` → Postgres will generate it)
        
        let newCouple =  CoupleInsert(inviter_id: inviter,
                                      invited_id: invited,
                                      accepted: false)
        return try await supabase
            .from("couples")
            .insert(newCouple)
            .select(selectClause)
            .single()
            .execute()
            .value
    }
}
