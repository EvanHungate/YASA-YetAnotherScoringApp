//
//  GameView.swift
//  YASA
//
//  Main game screen with scoring buttons
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @Binding var showControls: Bool
    @ObservedObject var connectivity = PhoneConnectivityManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                // Connection indicator
                HStack {
                    Spacer()
                    Circle()
                        .fill(connectivity.isReachable ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(connectivity.isReachable ? "Watch" : "Offline")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Text(gameState.currentRatioLabel())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)

                Text("Point \(gameState.totalPoints + 1)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if gameState.useLineRolling && !gameState.currentLineDisplay().isEmpty {
                    Text(gameState.currentLineDisplay())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 12)

            // Score Buttons
            HStack(spacing: 10) {
                // Team A
                TeamScoreButton(
                    teamName: gameState.teamAName,
                    score: gameState.scoreA,
                    breaks: gameState.breaksA,
                    isPulling: gameState.pullingTeam == "a",
                    color: .blue
                ) {
                    gameState.score(team: "a")
                }

                // Team B
                TeamScoreButton(
                    teamName: gameState.teamBName,
                    score: gameState.scoreB,
                    breaks: gameState.breaksB,
                    isPulling: gameState.pullingTeam == "b",
                    color: .red
                ) {
                    gameState.score(team: "b")
                }
            }
            .padding(.horizontal, 10)

            // Footer
            VStack(spacing: 12) {
                Button(action: {
                    showControls = true
                }) {
                    Text("Controls")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(white: 0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color.black)
        // Halftime Modal
        .alert("Halftime!", isPresented: $gameState.showHalftimeModal) {
            Button("Continue") {
                gameState.continueFromHalftime()
            }
        } message: {
            Text("Score: \(gameState.scoreA) - \(gameState.scoreB)")
        }
        // Finish screen
        .sheet(isPresented: $gameState.showWinnerModal) {
            FinishView(gameState: gameState)
                .interactiveDismissDisabled(true)
        }
    }
}

struct TeamScoreButton: View {
    let teamName: String
    let score: Int
    let breaks: Int
    let isPulling: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Status badge
                Text(isPulling ? "P" : "R")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(white: 0.25))
                    .cornerRadius(12)

                // Team name
                Text(teamName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                // Score
                Text("\(score)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Breaks
                if breaks > 0 {
                    Text("\(breaks) break\(breaks == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameView(gameState: GameState(), showControls: .constant(false))
}
