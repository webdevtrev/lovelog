//
//  RootView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/15/25.
//


// MARK: - RootView decides what to show
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        
            switch session.auth {
            case .unknown:
                SplashCheckingView()               // optional loading screen
            case .onboardingNeeded:
                OnboardingView()
            case .signedOut:
                AuthGateView(onSignIn: session.signIn) // your login/pair screen
            case .signedIn:
                ContentView()
            }
        
    }
}
