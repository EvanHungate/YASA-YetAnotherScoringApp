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
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Ultimate Frisbee")
                        .font(.headline)
                        .padding(.bottom, 4)

                    // Team Names
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Team Names")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Team A", text: $gameState.teamAName)

                        TextField("Team B", text: $gameState.teamBName)
                    }

                    Divider()

                    // First Pull
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Pull")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Picker("First Pull", selection: $gameState.initialPuller) {
                            Text(gameState.teamAName).tag("a")
                            Text(gameState.teamBName).tag("b")
                        }
                    }

                    Divider()

                    // Starting Ratio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Ratio")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Picker("Start Ratio", selection: $gameState.rotationStart) {
                            Text("Open").tag("O")
                            Text("FMP").tag("F")
                        }
                    }

                    Divider()

                    // Line Counts
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Line Counts")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Text("Open:")
                            Stepper("\(gameState.openCount)", value: $gameState.openCount, in: 1...14)
                        }

                        HStack {
                            Text("FMP:")
                            Stepper("\(gameState.fmpCount)", value: $gameState.fmpCount, in: 1...14)
                        }
                    }

                    Divider()

                    // Target Points
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Points")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Stepper("\(gameState.targetPoints) points", value: $gameState.targetPoints, in: 1...30)
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
}

#Preview {
    SetupView(gameState: GameState())
}
