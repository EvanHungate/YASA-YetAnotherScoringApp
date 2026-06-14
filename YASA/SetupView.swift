//
//  SetupView.swift
//  YASA
//
//  Setup screen for configuring a new game
//

import SwiftUI

struct SetupView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var connectivity = PhoneConnectivityManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Game Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                // Connection Status
                if connectivity.isActivated {
                    HStack {
                        Circle()
                            .fill(connectivity.isReachable ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        Text(connectivity.isReachable ? "Watch Connected" : "Watch Paired")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Team Names
                VStack(alignment: .leading, spacing: 12) {
                    Text("Team Names")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    TextField("Team A", text: $gameState.teamAName)
                        .textFieldStyle(DarkTextFieldStyle())

                    TextField("Team B", text: $gameState.teamBName)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                .padding(.horizontal)

                // Pulling Team
                VStack(alignment: .leading, spacing: 12) {
                    Text("Who Pulls First?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    HStack(spacing: 12) {
                        SelectButton(
                            title: gameState.teamAName.isEmpty ? "Team A" : gameState.teamAName,
                            isSelected: gameState.initialPuller == "a"
                        ) {
                            gameState.initialPuller = "a"
                            gameState.pullingTeam = "a"
                        }

                        SelectButton(
                            title: gameState.teamBName.isEmpty ? "Team B" : gameState.teamBName,
                            isSelected: gameState.initialPuller == "b"
                        ) {
                            gameState.initialPuller = "b"
                            gameState.pullingTeam = "b"
                        }
                    }
                }
                .padding(.horizontal)

                // Starting Ratio
                VStack(alignment: .leading, spacing: 12) {
                    Text("Starting Ratio")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    HStack(spacing: 12) {
                        SelectButton(
                            title: "Open (4:3)",
                            isSelected: gameState.rotationStart == "O"
                        ) {
                            gameState.rotationStart = "O"
                        }

                        SelectButton(
                            title: "FMP (4:3)",
                            isSelected: gameState.rotationStart == "F"
                        ) {
                            gameState.rotationStart = "F"
                        }
                    }
                }
                .padding(.horizontal)

                // Target Points
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Points")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    CounterRow(
                        title: "Points to Win",
                        value: $gameState.targetPoints,
                        minimum: 1
                    )
                }
                .padding(.horizontal)

                // Line Rolling Toggle
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $gameState.useLineRolling) {
                        Text("Use Line Rolling")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .tint(Color(red: 0.3, green: 0.7, blue: 0.65))

                    if gameState.useLineRolling {
                        VStack(spacing: 16) {
                            CounterRow(
                                title: "Open Players",
                                value: $gameState.openCount,
                                minimum: 1
                            )
                            CounterRow(
                                title: "FMP Players",
                                value: $gameState.fmpCount,
                                minimum: 1
                            )
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(white: 0.1),
                                    Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)

                // Start Button
                Button(action: {
                    gameState.startGame()
                }) {
                    Text("Start Game")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.9),
                                    Color(red: 0.3, green: 0.7, blue: 0.65)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.6), lineWidth: 2)
                        )
                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color.black)
    }
}

// MARK: - Custom Components

struct DarkTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(white: 0.1))
            .foregroundColor(.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(white: 0.2), lineWidth: 1)
            )
    }
}

struct SelectButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? Color(red: 0.3, green: 0.7, blue: 0.65) : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    isSelected 
                    ? LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.15),
                            Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.25)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    : LinearGradient(
                        gradient: Gradient(colors: [Color(white: 0.1), Color(white: 0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(red: 0.3, green: 0.7, blue: 0.65) : Color(white: 0.2), lineWidth: isSelected ? 2.5 : 2)
                )
        }
    }
}

struct CounterRow: View {
    let title: String
    @Binding var value: Int
    let minimum: Int

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    if value > minimum {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.2))
                        .clipShape(Circle())
                }

                Text("\(value)")
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 40)

                Button(action: {
                    value += 1
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.2))
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    SetupView(gameState: GameState())
}
