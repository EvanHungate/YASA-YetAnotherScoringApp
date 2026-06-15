//
//  ContentView.swift
//  YASA
//
//  Created by Evan Hungate on 2026-01-07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject private var connectivity = PhoneConnectivityManager.shared
    @State private var showResumeAlert = false
    @State private var showControls = false
    @State private var showSavedBanner = false

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
        .overlay(alignment: .top) { saveStatusBanner }
        .onAppear {
            if GameState.hasSavedGame() && !gameState.gameStarted {
                showResumeAlert = true
            }
        }
        .onChange(of: connectivity.lastSavedDate) { _, newValue in
            guard newValue != nil else { return }
            withAnimation { showSavedBanner = true }
            Task {
                try? await Task.sleep(for: .seconds(3))
                withAnimation { showSavedBanner = false }
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

    @ViewBuilder
    private var saveStatusBanner: some View {
        if let error = connectivity.lastError {
            bannerLabel(error, systemImage: "exclamationmark.triangle.fill", tint: .red)
        } else if showSavedBanner {
            bannerLabel("Scorecard saved to Photos", systemImage: "checkmark.circle.fill", tint: .green)
        }
    }

    private func bannerLabel(_ text: String, systemImage: String, tint: Color) -> some View {
        Label(text, systemImage: systemImage)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .foregroundStyle(tint)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}
