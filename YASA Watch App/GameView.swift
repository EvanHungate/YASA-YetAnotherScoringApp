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
        ScrollView {
            VStack(spacing: 8) {
                // Ratio and Line Display
                VStack(spacing: 4) {
                    Text(gameState.currentRatioLabel())
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(gameState.currentLineDisplay())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                Divider()

                // Team A Score Section
                VStack(spacing: 8) {
                    HStack {
                        Text(gameState.teamAName)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Spacer()

                        if gameState.pullingTeam == "a" {
                            Text("Pulling")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        } else {
                            Text("Receiving")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }

                    HStack {
                        Text("\(gameState.scoreA)")
                            .font(.system(size: 40, weight: .bold))
                            .frame(maxWidth: .infinity)

                        Button(action: {
                            gameState.score(team: "a")
                        }) {
                            Text("+1")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }

                    Text("Breaks: \(gameState.breaksA)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                Divider()

                // Team B Score Section
                VStack(spacing: 8) {
                    HStack {
                        Text(gameState.teamBName)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Spacer()

                        if gameState.pullingTeam == "b" {
                            Text("Pulling")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        } else {
                            Text("Receiving")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }

                    HStack {
                        Text("\(gameState.scoreB)")
                            .font(.system(size: 40, weight: .bold))
                            .frame(maxWidth: .infinity)

                        Button(action: {
                            gameState.score(team: "b")
                        }) {
                            Text("+1")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }

                    Text("Breaks: \(gameState.breaksB)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                Divider()

                // Game Info
                HStack {
                    Text("Point \(gameState.totalPoints + 1)")
                        .font(.caption)
                    Spacer()
                    Text("Game to \(gameState.targetPoints)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        gameState.undo()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!gameState.canUndo())

                    Button(action: {
                        gameState.resetGame()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                .padding(.top, 4)
            }
            .padding()
        }
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
