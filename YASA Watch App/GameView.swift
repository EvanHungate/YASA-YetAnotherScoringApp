//
//  GameView.swift
//  YASA Watch App
//
//  Main game screen with scoring and game state display
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 6) {
            // Ratio and optional line display
            VStack(spacing: 2) {
                Text(gameState.currentRatioLabel())
                    .font(.title3)
                    .fontWeight(.bold)

                if !gameState.currentLineDisplay().isEmpty {
                    Text(gameState.currentLineDisplay())
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Team A Score Section
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(gameState.teamAName)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        if gameState.pullingTeam == "a" {
                            Text("P")
                                .font(.system(size: 8))
                                .foregroundColor(.orange)
                        } else {
                            Text("R")
                                .font(.system(size: 8))
                                .foregroundColor(.green)
                        }
                    }

                    Text("\(gameState.scoreA)")
                        .font(.system(size: 36, weight: .bold))

                    Text("Breaks: \(gameState.breaksA)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    gameState.score(team: "a")
                }) {
                    Text("+1")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 45, height: 45)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }

            Divider()

            // Team B Score Section
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(gameState.teamBName)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        if gameState.pullingTeam == "b" {
                            Text("P")
                                .font(.system(size: 8))
                                .foregroundColor(.orange)
                        } else {
                            Text("R")
                                .font(.system(size: 8))
                                .foregroundColor(.green)
                        }
                    }

                    Text("\(gameState.scoreB)")
                        .font(.system(size: 36, weight: .bold))

                    Text("Breaks: \(gameState.breaksB)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    gameState.score(team: "b")
                }) {
                    Text("+1")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 45, height: 45)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }

            Divider()

            // Game Info and Controls
            HStack {
                Text("Pt \(gameState.totalPoints + 1)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)

                Spacer()

                Text("to \(gameState.targetPoints)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    gameState.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(!gameState.canUndo())

                Button(action: {
                    gameState.resetGame()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
        }
        .padding()
        .alert("Halftime", isPresented: $gameState.showHalftimeModal) {
            Button("Continue") {
                gameState.continueFromHalftime()
            }
        } message: {
            Text("8 points reached. Switching sides.")
        }
        .alert("Game Over!", isPresented: $gameState.showWinnerModal) {
            Button("New Game") {
                gameState.resetGame()
            }
        } message: {
            let winnerName = gameState.winningTeam == "a" ? gameState.teamAName : gameState.teamBName
            let winnerScore = gameState.winningTeam == "a" ? gameState.scoreA : gameState.scoreB
            let loserScore = gameState.winningTeam == "a" ? gameState.scoreB : gameState.scoreA
            Text("\(winnerName) wins \(winnerScore)-\(loserScore)!")
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.gameStarted = true
    gameState.rotationCycle = gameState.buildRotation(startRatio: "O")
    return GameView(gameState: gameState)
}
