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
        VStack(spacing: 4) {
            // Ratio and optional line display at top
            VStack(spacing: 2) {
                HStack {
                    Text("Pt \(gameState.totalPoints + 1)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(gameState.currentRatioLabel())
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    Text("to \(gameState.targetPoints)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                if !gameState.currentLineDisplay().isEmpty {
                    Text(gameState.currentLineDisplay())
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // Team A - Large Button
            Button(action: {
                gameState.score(team: "a")
            }) {
                VStack(spacing: 4) {
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

                    Text("\(gameState.scoreA)")
                        .font(.system(size: 50, weight: .bold))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)

            // Team B - Large Button
            Button(action: {
                gameState.score(team: "b")
            }) {
                VStack(spacing: 4) {
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

                    Text("\(gameState.scoreB)")
                        .font(.system(size: 50, weight: .bold))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.2))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)

            // Controls at bottom
            HStack(spacing: 8) {
                Button(action: {
                    gameState.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(!gameState.canUndo())

                Spacer()

                Button(action: {
                    gameState.resetGame()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                        Text("Reset")
                            .font(.system(size: 10))
                    }
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
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
