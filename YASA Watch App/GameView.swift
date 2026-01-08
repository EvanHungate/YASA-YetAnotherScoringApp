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
        VStack(spacing: 8) {
            // Team A - Large Button with all info
            Button(action: {
                gameState.score(team: "a")
            }) {
                VStack(spacing: 6) {
                    // Top row: Team name and status
                    HStack {
                        Text(gameState.teamAName)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Spacer()

                        HStack(spacing: 4) {
                            Text("B:\(gameState.breaksA)")
                                .font(.system(size: 9))

                            Text(gameState.pullingTeam == "a" ? "P" : "R")
                                .font(.system(size: 9))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(gameState.pullingTeam == "a" ? Color.orange.opacity(0.3) : Color.green.opacity(0.3))
                                .cornerRadius(4)
                        }
                    }

                    // Score - large and centered
                    Text("\(gameState.scoreA)")
                        .font(.system(size: 56, weight: .bold))

                    // Bottom row: Ratio and line info
                    VStack(spacing: 2) {
                        Text(gameState.currentRatioLabel())
                            .font(.caption)
                            .fontWeight(.semibold)

                        if !gameState.currentLineDisplay().isEmpty {
                            Text(gameState.currentLineDisplay())
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

            // Team B - Large Button with all info
            Button(action: {
                gameState.score(team: "b")
            }) {
                VStack(spacing: 6) {
                    // Top row: Team name and status
                    HStack {
                        Text(gameState.teamBName)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Spacer()

                        HStack(spacing: 4) {
                            Text("B:\(gameState.breaksB)")
                                .font(.system(size: 9))

                            Text(gameState.pullingTeam == "b" ? "P" : "R")
                                .font(.system(size: 9))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(gameState.pullingTeam == "b" ? Color.orange.opacity(0.3) : Color.green.opacity(0.3))
                                .cornerRadius(4)
                        }
                    }

                    // Score - large and centered
                    Text("\(gameState.scoreB)")
                        .font(.system(size: 56, weight: .bold))

                    // Bottom row: Ratio and line info
                    VStack(spacing: 2) {
                        Text(gameState.currentRatioLabel())
                            .font(.caption)
                            .fontWeight(.semibold)

                        if !gameState.currentLineDisplay().isEmpty {
                            Text(gameState.currentLineDisplay())
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.2))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
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
