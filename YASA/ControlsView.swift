//
//  ControlsView.swift
//  YASA
//
//  Controls and information screen
//

import SwiftUI

struct ControlsView: View {
    @ObservedObject var gameState: GameState
    @Binding var showControls: Bool
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        showControls = false
                    }) {
                        Text("← Back")
                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.65))
                            .font(.body)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    Text("Controls")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer for balance
                    Text("← Back")
                        .foregroundColor(.clear)
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // Game Info
                VStack(spacing: 0) {
                    InfoRow(label: "Score", value: "\(gameState.scoreA) - \(gameState.scoreB)")
                    InfoRow(label: "Breaks", value: "\(gameState.breaksA) - \(gameState.breaksB)")
                    InfoRow(label: "Current Ratio", value: gameState.currentRatioLabel())
                    InfoRow(label: "Pulling Team", value: gameState.pullingTeam == "a" ? gameState.teamAName : gameState.teamBName)

                    if gameState.useLineRolling {
                        InfoRow(label: "Current Line", value: gameState.currentLineDisplay())
                    }

                    InfoRow(label: "Target", value: "\(gameState.targetPoints) points")

                    if gameState.halftimeReached {
                        InfoRow(label: "Status", value: "Second Half", valueColor: Color(red: 1.0, green: 0.7, blue: 0.5))
                    }
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.1),
                            Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.15)
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
                .padding(.horizontal)

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        gameState.undo()
                    }) {
                        Text("Undo Last Score")
                            .font(.headline)
                            .foregroundColor(gameState.canUndo() ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(white: 0.2),
                                        Color(white: 0.15)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(gameState.canUndo() ? Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.4) : Color(white: 0.2), lineWidth: 1.5)
                            )
                    }
                    .disabled(!gameState.canUndo())

                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Text("Reset Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.5, blue: 0.4).opacity(0.6),
                                        Color(red: 1.0, green: 0.5, blue: 0.4).opacity(0.8)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 1.0, green: 0.7, blue: 0.5).opacity(0.5), lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal)

                // Rotation Cycle
                VStack(spacing: 12) {
                    Text("Rotation Cycle")
                        .font(.body)
                        .foregroundColor(.gray)

                    HStack(spacing: 8) {
                        ForEach(Array(gameState.rotationCycle.enumerated()), id: \.offset) { index, ratio in
                            Text(ratio)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(index == gameState.rotationIndex ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    index == gameState.rotationIndex 
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.8),
                                            Color(red: 0.3, green: 0.7, blue: 0.65)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            index == gameState.rotationIndex 
                                            ? Color(red: 0.3, green: 0.7, blue: 0.65).opacity(0.6)
                                            : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                        }
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.1),
                            Color(red: 1.0, green: 0.7, blue: 0.5).opacity(0.12)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 1.0, green: 0.7, blue: 0.5).opacity(0.25), lineWidth: 1)
                )
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .background(Color.black)
        .alert("Reset Game?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameState.resetGame()
                showControls = false
            }
        } message: {
            Text("All progress will be lost.")
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(valueColor)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .fill(Color(white: 0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    ControlsView(gameState: GameState(), showControls: .constant(true))
}
