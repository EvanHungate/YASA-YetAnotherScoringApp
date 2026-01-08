//
//  ControlsView.swift
//  YASA Watch App
//
//  Game controls and information
//

import SwiftUI

struct ControlsView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Game Info
                VStack(spacing: 8) {
                    Text("Game Info")
                        .font(.headline)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Point")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(gameState.totalPoints + 1)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Target Points")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(gameState.targetPoints)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }

                    Divider()

                    // Current Scores
                    HStack {
                        VStack(spacing: 4) {
                            Text(gameState.teamAName)
                                .font(.caption)
                            Text("\(gameState.scoreA)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("\(gameState.breaksA) breaks")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        Text(":")
                            .font(.title)
                            .foregroundColor(.secondary)

                        VStack(spacing: 4) {
                            Text(gameState.teamBName)
                                .font(.caption)
                            Text("\(gameState.scoreB)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("\(gameState.breaksB) breaks")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                Divider()

                // Control Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        gameState.undo()
                    }) {
                        Label("Undo Last Point", systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!gameState.canUndo())

                    Button(action: {
                        gameState.resetGame()
                    }) {
                        Label("Reset Game", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
            .padding()
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.gameStarted = true
    gameState.scoreA = 7
    gameState.scoreB = 5
    gameState.breaksA = 2
    gameState.breaksB = 1
    gameState.totalPoints = 12
    return ControlsView(gameState: gameState)
}
