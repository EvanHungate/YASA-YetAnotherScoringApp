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
            VStack(spacing: 8) {
                Text("Setup")
                    .font(.title3)
                    .fontWeight(.semibold)

            // Team Names - compact
            HStack {
                TextField("Team", text: $gameState.teamAName)
                    .font(.caption)
                Text("vs")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("Opposition", text: $gameState.teamBName)
                    .font(.caption)
            }

            Divider()

            // First Pull - compact
            HStack {
                Text("First Pull:")
                    .font(.caption2)
                Picker("", selection: $gameState.initialPuller) {
                    Text(gameState.teamAName).tag("a")
                    Text(gameState.teamBName).tag("b")
                }
                .labelsHidden()
            }

            // Starting Ratio - compact
            HStack {
                Text("Start:")
                    .font(.caption2)
                Picker("", selection: $gameState.rotationStart) {
                    Text("Open").tag("O")
                    Text("FMP").tag("F")
                }
                .labelsHidden()
            }

            // Target Points - compact
            HStack {
                Text("Game to:")
                    .font(.caption2)
                Stepper("\(gameState.targetPoints)", value: $gameState.targetPoints, in: 1...30)
                    .font(.caption2)
            }

            Divider()

            // Line Rolling Toggle
            Toggle("Line Rolling", isOn: $gameState.useLineRolling)
                .font(.caption2)

            // Show line counts only if line rolling is enabled
            if gameState.useLineRolling {
                HStack {
                    Text("Open:")
                        .font(.caption2)
                    Stepper("\(gameState.openCount)", value: $gameState.openCount, in: 1...14)
                        .font(.caption2)
                }

                HStack {
                    Text("FMP:")
                        .font(.caption2)
                    Stepper("\(gameState.fmpCount)", value: $gameState.fmpCount, in: 1...14)
                        .font(.caption2)
                }
            }

            Divider()

            // Start Button
            Button(action: {
                gameState.startGame()
            }) {
                Text("Start Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    SetupView(gameState: GameState())
}
