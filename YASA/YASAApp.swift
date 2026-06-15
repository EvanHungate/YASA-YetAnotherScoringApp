//
//  YASAApp.swift
//  YASA
//
//  Created by Evan Hungate on 2026-01-07.
//

import SwiftUI

@main
struct YASAApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var connectivity = PhoneConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .onAppear {
                    // Initialize WatchConnectivity with game state
                    connectivity.activate(with: gameState)
                }
        }
    }
}
