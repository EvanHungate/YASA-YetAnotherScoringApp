//
//  ContentView.swift
//  YASA
//
//  Created by Evan Hungate on 2026-01-07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showResumeAlert = false
    @State private var showControls = false

    var body: some View {
        Group {
            if !gameState.gameStarted {
                SetupView(gameState: gameState)
            } else if showControls {
                ControlsView(gameState: gameState, showControls: $showControls)
            } else {
                GameView(gameState: gameState, showControls: $showControls)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if GameState.hasSavedGame() && !gameState.gameStarted {
                showResumeAlert = true
            }
        }
        .alert("Resume Game?", isPresented: $showResumeAlert) {
            Button("Resume") {
                _ = gameState.loadSavedState()
            }
            Button("New Game", role: .cancel) {
                gameState.clearSavedState()
            }
        } message: {
            Text("You have a game in progress. Would you like to resume it?")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}
