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
            GameView(gameState: gameState)
        } else {
            SetupView(gameState: gameState)
        }
    }
}

#Preview {
    ContentView()
}
