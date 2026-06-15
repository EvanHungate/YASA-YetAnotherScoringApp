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
        VStack(spacing: 0) {
            // Gender ratio at top left
            HStack {
                Text(gameState.currentRatioLabel())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                
                Spacer()
            }
            .background(Color(white: 0.15))
            
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
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(gameState.pullingTeam == "a" ? Color(red: 1.0, green: 0.7, blue: 0.5) : Color(red: 0.3, green: 0.7, blue: 0.65))
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)

                        Spacer()

                        // Score - large and centered
                        Text("\(gameState.scoreA)")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        // Bottom section: Line info and breaks
                        HStack(alignment: .bottom) {
                            if !gameState.currentLineDisplay().isEmpty {
                                Text(gameState.currentLineDisplay())
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(2)
                            } else {
                                Spacer()
                            }

                            Spacer()

                            Text("B: \(gameState.breaksA)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.95))
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.8), lineWidth: 3)
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
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(gameState.pullingTeam == "b" ? Color(red: 1.0, green: 0.7, blue: 0.5) : Color(red: 0.3, green: 0.7, blue: 0.65))
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    Spacer()

                    // Score - large and centered
                    Text("\(gameState.scoreB)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Bottom section: Line info and breaks
                    HStack(alignment: .bottom) {
                        if !gameState.currentLineDisplay().isEmpty {
                            Text(gameState.currentLineDisplay())
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(2)
                        } else {
                            Spacer()
                        }

                        Spacer()

                        Text("B: \(gameState.breaksB)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.95))
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 1.0, green: 0.7, blue: 0.5).opacity(0.8), lineWidth: 3)
                )
            }
            .buttonStyle(.plain)
            }
            .padding(4)
            .background(Color.black)
        }
        .alert("Halftime", isPresented: $gameState.showHalftimeModal) {
            Button("Continue") {
                gameState.continueFromHalftime()
            }
        } message: {
            Text("8 points reached. Switching sides.")
        }
        .sheet(isPresented: $gameState.showWinnerModal) {
            FinishView(gameState: gameState)
                .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.gameStarted = true
    gameState.rotationCycle = ["O2", "F1", "F2", "O1"]
    return GameView(gameState: gameState)
}
