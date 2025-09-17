//
//  SupabaseAuthStore.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/17/25.
//


import Supabase
import SwiftUI

enum AuthState: Equatable {
    case unknown               // launching / checking tokens
    case signedOut             // not logged in / not paired
    case onboardingNeeded      // show your onboarding flow
    case signedIn              // main app
}

@MainActor
final class SupabaseAuthStore: ObservableObject {
    @Published private(set) var auth: AuthState = .unknown
    @Published private(set) var user: Auth.User?
    init() {
        Task { await bootstrap() }
      }

      /// Called once on app launch.
      func bootstrap() async {
          do {
                let session = try await supabase.auth.session
                self.user = session.user
                self.auth = .signedIn
              } catch {
                self.user = nil
                  self.auth = .signedOut
              }
      }
  func signInWithApple() async throws {
    try await supabase.auth.signInWithOAuth(
      provider: .apple,
      redirectTo: URL(string: "lovelog://auth-callback")!
    )
  }
  func handle(_ url: URL) {
    supabase.auth.handle(url)
  }
  func signOut() async throws {
    try await supabase.auth.signOut()
      auth = .signedOut
  }
    func signIn() {
        auth = .signedIn
    }

}
