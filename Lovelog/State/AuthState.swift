//
//  AuthState.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/15/25.
//


import SwiftUI
import Combine

// MARK: - Auth + App State

enum AuthState: Equatable {
    case unknown               // launching / checking tokens
    case signedOut             // not logged in / not paired
    case onboardingNeeded      // show your onboarding flow
    case signedIn              // main app
}

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var auth: AuthState = .unknown

    // Persist whether user finished onboarding at least once
    @AppStorage("hasFinishedOnboarding") private var hasFinishedOnboarding: Bool = false

    init() {
        bootstrap()
    }

    func bootstrap() {
        // Mock “check auth/refresh token/paired/user” work.
        // Replace with real checks when you wire a backend.
        if isUserSignedIn() {
            auth = .signedIn
        } else {
            auth = hasFinishedOnboarding ? .signedOut : .onboardingNeeded
        }
    }

    // MARK: - Transitions

    func finishedOnboarding() {
        hasFinishedOnboarding = true
        // After onboarding, decide where to go:
        // If they must log in/pair, go to signedOut; otherwise go to signedIn.
        auth = isUserSignedIn() ? .signedIn : .signedOut
    }

    func signIn() {
        // Mock sign in
        auth = .signedIn
    }

    func signOut() {
        auth = .signedOut
    }

    // MARK: - Replace with real logic
    private func isUserSignedIn() -> Bool {
        return false // mock: not signed in yet / not paired
    }
}
