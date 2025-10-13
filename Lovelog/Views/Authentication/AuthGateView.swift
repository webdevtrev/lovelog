//
//  AuthGateView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/15/25.
//
import SwiftUI

struct AuthGateView: View {
  @EnvironmentObject private var authStore: SupabaseAuthStore
  let onSignIn: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Text("Welcome to Love Log")
        .font(.largeTitle.bold())
      Text("Please sign in or pair with your partner to continue.")
      Button("Sign in with Apple") {
        Task {
            authStore.signInWithAppleNative()
            onSignIn()
        }
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
  }
}

#Preview{
    AuthGateView(onSignIn: test)
}
