//
//  ControlsView.swift
//  YASA Watch App
//
//  Game controls and information
//

import SwiftUI

struct ControlsView: View {
    @ObservedObject var gameState: GameState
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Controls")
                    .font(YASAFont.display(15))
                    .foregroundColor(.white)
                    .padding(.top, 2)

                VStack(spacing: 6) {
                    HStack {
                        scoreColumn(name: gameState.teamAName, score: gameState.scoreA, breaks: gameState.breaksA)
                        Text(":")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(YASAColor.textMuted)
                        scoreColumn(name: gameState.teamBName, score: gameState.scoreB, breaks: gameState.breaksB)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
                .background(YASAColor.cardFill)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Rectangle().fill(YASAColor.divider).frame(height: 1)

                VStack(spacing: 8) {
                    Button {
                        gameState.undo()
                    } label: {
                        Text("↺ Undo Point")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(gameState.canUndo() ? .white : YASAColor.disabled)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: Color(white: 0.114), lip: .black))
                    .disabled(!gameState.canUndo())

                    Button {
                        gameState.finishGame()
                    } label: {
                        Text("Finish Game")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip))

                    Button {
                        showResetConfirmation = true
                    } label: {
                        Text("Reset Game")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.teamB, lip: YASAColor.teamBLip))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(YASAColor.screenBlack)
        .alert("Reset Game?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameState.resetGame()
            }
        } message: {
            Text("All progress will be lost.")
        }
    }

    private func scoreColumn(name: String, score: Int, breaks: Int) -> some View {
        VStack(spacing: 2) {
            Text(name)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(YASAColor.textDim)
                .lineLimit(1)
            Text("\(score)")
                .font(YASAFont.display(26))
                .foregroundColor(.white)
            Text("\(breaks) brk")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundColor(YASAColor.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Flat (no-lip) chip button used for the Watch ratio/segment chips.
struct FlatChipButtonStyle: ButtonStyle {
    var fill: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(RoundedRectangle(cornerRadius: 9).fill(fill))
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    let gameState = GameState()
    gameState.gameStarted = true
    gameState.scoreA = 7
    gameState.scoreB = 5
    gameState.breaksA = 2
    gameState.breaksB = 1
    gameState.totalPoints = 12
    return ControlsView(gameState: gameState)
}
