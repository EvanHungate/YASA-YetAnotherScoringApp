//
//  ContentView.swift
//  YASA Watch App
//
//  Created by Evan Hungate on 2026-01-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
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
}

#Preview {
    ContentView()
}
