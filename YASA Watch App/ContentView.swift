//
//  ContentView.swift
//  YASA Watch App
//
//  Created by Evan Hungate on 2026-01-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var showResumeAlert = false

    var body: some View {
        Group {
            if gameState.gameStarted {
                TabView {
                    GameView(gameState: gameState)
                        .tabItem {
                            Label("Game", systemImage: "sportscourt")
                        }

                    ControlsView(gameState: gameState)
                        .tabItem {
                            Label("Controls", systemImage: "gearshape")
                        }
                }
                .preferredColorScheme(.dark)
            } else {
                SetupView(gameState: gameState)
                    .preferredColorScheme(.dark)
            }
        }
        .onAppear {
            // Check for saved game on app launch
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
}
