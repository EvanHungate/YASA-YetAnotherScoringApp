//
//  SetupView.swift
//  YASA Watch App
//
//  Setup screen for configuring game settings
//

import SwiftUI

struct SetupView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Team Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Team Name")
                        .font(.caption)
                        .fontWeight(.semibold)
                    TextField("Team", text: $gameState.teamAName)
                        .foregroundColor(.secondary)
                }

                // Opponent Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Opponent Name")
                        .font(.caption)
                        .fontWeight(.semibold)
                    TextField("Opponent", text: $gameState.teamBName)
                        .foregroundColor(.secondary)
                }

                // Pulling Team
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pulling Team")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Picker("", selection: $gameState.initialPuller) {
                        Text(gameState.teamAName).tag("a")
                        Text(gameState.teamBName).tag("b")
                    }
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Start Ratio
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Ratio")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Picker("", selection: $gameState.rotationStart) {
                        Text("Open").tag("O")
                        Text("FMP").tag("F")
                    }
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Game to Score
                VStack(alignment: .leading, spacing: 4) {
                    Text("Game to Score")
                        .font(.caption)
                        .fontWeight(.semibold)

                    HStack(spacing: 12) {
                        Button(action: {
                            if gameState.targetPoints > 1 {
                                gameState.targetPoints -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)

                        Text("\(gameState.targetPoints)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(minWidth: 30)

                        Button(action: {
                            if gameState.targetPoints < 30 {
                                gameState.targetPoints += 1
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Track Line Roll
                HStack {
                    Text("Track Line Roll")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Toggle("", isOn: $gameState.useLineRolling)
                        .labelsHidden()
                }

                // Open Players (only show if line rolling is enabled)
                if gameState.useLineRolling {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Open Players")
                            .font(.caption)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            Button(action: {
                                if gameState.openCount > 1 {
                                    gameState.openCount -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(.plain)

                            Text("\(gameState.openCount)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(minWidth: 30)

                            Button(action: {
                                if gameState.openCount < 14 {
                                    gameState.openCount += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // FMP Players
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FMP Players")
                            .font(.caption)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            Button(action: {
                                if gameState.fmpCount > 1 {
                                    gameState.fmpCount -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(.plain)

                            Text("\(gameState.fmpCount)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(minWidth: 30)

                            Button(action: {
                                if gameState.fmpCount < 14 {
                                    gameState.fmpCount += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Start Button
                Button(action: {
                    gameState.startGame()
                }) {
                    Text("Start Game")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

#Preview {
    SetupView(gameState: GameState())
}
