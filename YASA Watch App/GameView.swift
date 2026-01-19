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
        HStack(spacing: 4) {
            // Team A - Left Button
            Button(action: {
                gameState.score(team: "a")
            }) {
                VStack(spacing: 0) {
                    // Top section: Team name and P/R badge
                    HStack {
                        Text(gameState.teamAName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)

                        Spacer()

                        Text(gameState.pullingTeam == "a" ? "P" : "R")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(gameState.pullingTeam == "a" ? .orange : .green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    Spacer()

                    // Score - large and centered
                    Text("\(gameState.scoreA)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Bottom section: Ratio/Line info and breaks
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(gameState.currentRatioLabel())
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))

                            if !gameState.currentLineDisplay().isEmpty {
                                Text(gameState.currentLineDisplay())
                                    .font(.system(size: 7))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(2)
                            }
                        }

                        Spacer()

                        Text("B:\(gameState.breaksA)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)

            // Team B - Right Button
            Button(action: {
                gameState.score(team: "b")
            }) {
                VStack(spacing: 0) {
                    // Top section: Team name and P/R badge
                    HStack {
                        Text(gameState.teamBName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)

                        Spacer()

                        Text(gameState.pullingTeam == "b" ? "P" : "R")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(gameState.pullingTeam == "b" ? .orange : .green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    Spacer()

                    // Score - large and centered
                    Text("\(gameState.scoreB)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Bottom section: Ratio/Line info and breaks
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(gameState.currentRatioLabel())
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))

                            if !gameState.currentLineDisplay().isEmpty {
                                Text(gameState.currentLineDisplay())
                                    .font(.system(size: 7))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(2)
                            }
                        }

                        Spacer()

                        Text("B:\(gameState.breaksB)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red.opacity(0.6), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(4)
        .background(Color.black)
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
