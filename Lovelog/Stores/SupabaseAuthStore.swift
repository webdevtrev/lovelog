//
//  SupabaseAuthStore.swift
//  LoveLog
//
//  Created by Trevor Cash on 9/17/25.
//

import SwiftUI
import AuthenticationServices
import Supabase
import CryptoKit
import Security

enum AuthState: Equatable {
  case unknown           // launching / checking tokens
  case signedOut         // not logged in / not paired
  case onboardingNeeded  // first-run / gated onboarding
  case signedIn          // main app
}

@MainActor
final class SupabaseAuthStore: NSObject, ObservableObject {
  // MARK: - Supabase client
  private let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://vwdgxmmhfisefsbvepig.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3ZGd4bW1oZmlzZWZzYnZlcGlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3MDMyNTIsImV4cCI6MjA3MzI3OTI1Mn0.iPGo3RfRu2Lx9k7diteJcGsw09aj3R9SI8eWfX_19KQ"
    // If you use multiple targets/schemes, consider pinning Keychain storage
    // via options.auth.storage to avoid sessions "disappearing" between builds.
  )

  @Published var auth: AuthState = .unknown
  @Published private(set) var user: Auth.User?
  @Published var lastError: String?

  private var currentNonce: String?
  private var authChangeListener: (any AuthStateChangeListenerRegistration)?

  override init() {
    super.init()
    Task { await configureAndBootstrap() }
  }

  // MARK: - Launch bootstrap
  /// Load saved session from Keychain (via `auth.session`), then observe changes.
  private func configureAndBootstrap() async {
    await bootstrap()
      await observeAuthStateChanges()
  }

  func bootstrap() async {
    do {
      // Reading `session` restores the persisted session from Keychain if present.
      let session = try await supabase.auth.session
      self.user = session.user

      struct UserRow: Decodable { let id: UUID; let onboarded: Bool? }
      let dbUser: UserRow? = try? await supabase
        .from("users")
        .select("id, onboarded")
        .eq("id", value: session.user.id)
        .single()
        .execute()
        .value

      let finished = dbUser?.onboarded ?? false
      self.auth = finished ? .signedIn : .onboardingNeeded
    } catch {
      self.user = nil
      self.auth = .signedOut
    }
  }

    private func observeAuthStateChanges() async {
        authChangeListener = await supabase.auth.onAuthStateChange { [weak self] event, session in
        guard let self else { return }

        switch event {
        case .signedIn, .tokenRefreshed:
          guard let session else { return }

          // Create an async context for the DB call
          Task.detached { [weak self] in
            guard let self else { return }
            // async work OFF the main actor
            let finished = (try? await self.isOnboarded(userId: session.user.id)) ?? false

            // hop to main thread for @Published mutations (no await here)
            DispatchQueue.main.async {
              self.user = session.user
              self.auth = finished ? .signedIn : .onboardingNeeded
            }
          }

        case .signedOut:
          // no async/await needed for this path
          DispatchQueue.main.async {
            self.user = nil
            self.auth = .signedOut
          }

        default:
          break
        }
      }
    }






  // MARK: - Native Sign in with Apple (no web sheet)
  func signInWithAppleNative() {
    let nonce = makeRandomNonce()
    currentNonce = nonce

    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce) // Apple gets the HASHED nonce

    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }

  // MARK: - Sign out
  func signOut() async {
    do {
      try await supabase.auth.signOut()
      user = nil
      auth = .signedOut
    } catch {
      lastError = "Sign out failed: \(error.localizedDescription)"
    }
  }

  // MARK: - App user helpers (inside the class)

  private func isOnboarded(userId: UUID) async throws -> Bool {
    struct Row: Decodable { let onboarded: Bool }
    let row: Row = try await supabase
      .from("users")
      .select("onboarded")
      .eq("id", value: userId) // use userId.uuidString if column is TEXT
      .single()
      .execute()
      .value
    return row.onboarded
  }

  /// Creates a users row if missing. Safe to call repeatedly.
  private func createUserIfNeeded(authUser: Auth.User, name: String?) async {
    let exists: Bool = (try? await supabase
      .from("users")
      .select("id")
      .eq("id", value: authUser.id)
      .single()
      .execute()
      .value
    ) != nil

    guard !exists else { return }

    struct NewUser: Encodable {
      let id: UUID
      let name: String?
    }

    do {
      _ = try await supabase
        .from("users")
        .insert(NewUser(id: authUser.id, name: name))
        .execute()
    } catch {
      self.lastError = "Failed to create user: \(error.localizedDescription)"
    }
  }
}

// MARK: - ASAuthorizationControllerDelegate
extension SupabaseAuthStore: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    guard
      let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
      let tokenData = credential.identityToken,
      let idToken = String(data: tokenData, encoding: .utf8),
      let rawNonce = currentNonce
    else {
      self.lastError = "Missing Apple ID token or nonce."
      return
    }

    Task {
      do {
        _ = try await supabase.auth.signInWithIdToken(
          credentials: .init(provider: .apple, idToken: idToken, nonce: rawNonce)
        )

        if let user = supabase.auth.currentUser {
          let given = credential.fullName?.givenName
          await createUserIfNeeded(authUser: user, name: given)
        }

        if let session = try? await supabase.auth.session {
          self.user = session.user
          let finished = (try? await isOnboarded(userId: session.user.id)) ?? false
          self.auth = finished ? .signedIn : .onboardingNeeded
        } else {
          self.user = supabase.auth.currentUser
          self.auth = .signedOut
        }

        self.lastError = nil
        self.currentNonce = nil
      } catch {
        self.lastError = "Supabase sign-in failed: \(error.localizedDescription)"
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithError error: Error) {
    self.lastError = "Apple sign-in failed: \(error.localizedDescription)"
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension SupabaseAuthStore: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    #if canImport(UIKit)
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    #else
    return ASPresentationAnchor()
    #endif
  }
}

// MARK: - Nonce helpers
private func makeRandomNonce(length: Int = 32) -> String {
  precondition(length > 0)
  let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remaining = length

  while remaining > 0 {
    var randoms = [UInt8](repeating: 0, count: 16)
    let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
    if status != errSecSuccess { fatalError("Unable to generate nonce.") }
    for random in randoms {
      if remaining == 0 { break }
      if random < charset.count {
        result.append(charset[Int(random)])
        remaining -= 1
      }
    }
  }
  return result
}

private func sha256(_ input: String) -> String {
  let hashed = SHA256.hash(data: Data(input.utf8))
  return hashed.map { String(format: "%02x", $0) }.joined()
}
