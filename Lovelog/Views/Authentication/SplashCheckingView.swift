//
//  SplashCheckingView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/15/25.
//
import SwiftUI

struct SplashCheckingView: View {
    var body: some View {
        ProgressView("Checking session…")
            .progressViewStyle(.circular)
            .padding()
    }
}
