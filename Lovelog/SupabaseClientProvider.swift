//
//  SupabaseClientProvider.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/16/25.
//


import Supabase
import Foundation

// ⚠️ Replace with your actual values
private let supabaseUrl = URL(string: "https://vwdgxmmhfisefsbvepig.supabase.co")!
private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3ZGd4bW1oZmlzZWZzYnZlcGlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3MDMyNTIsImV4cCI6MjA3MzI3OTI1Mn0.iPGo3RfRu2Lx9k7diteJcGsw09aj3R9SI8eWfX_19KQ"

// This is now available anywhere in the app
let supabase = SupabaseClient(
  supabaseURL: supabaseUrl,
  supabaseKey: supabaseAnonKey
)
