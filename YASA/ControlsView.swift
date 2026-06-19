//
//  ControlsView.swift
//  YASA
//
//  Controls / settings sheet — live overrides + game actions
//

import SwiftUI

struct ControlsView: View {
    @ObservedObject var gameState: GameState
    @Binding var showControls: Bool
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Button { showControls = false } label: {
                        Text("‹ Back")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(YASAColor.primary)
                    }
                    Spacer()
                    Text("Controls")
                        .font(YASAFont.display(24))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Back").font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.clear)
                }

                // ADJUST
                VStack(alignment: .leading, spacing: 11) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("ADJUST").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(1.4).foregroundColor(YASAColor.textMuted)
                        Text("overrides the live game").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(YASAColor.textFaint)
                    }
                    VStack(spacing: 0) {
                        subheader("SCORE")
                        adjustRow(dot: YASAColor.teamA, name: gameState.teamAName, value: gameState.scoreA,
                                  dec: { gameState.adjustScore(team: "a", delta: -1) },
                                  inc: { gameState.adjustScore(team: "a", delta: 1) })
                        adjustRow(dot: YASAColor.teamB, name: gameState.teamBName, value: gameState.scoreB,
                                  dec: { gameState.adjustScore(team: "b", delta: -1) },
                                  inc: { gameState.adjustScore(team: "b", delta: 1) }, divider: true)
                        subheader("BREAKS")
                        adjustRow(dot: YASAColor.teamA, name: gameState.teamAName, value: gameState.breaksA,
                                  dec: { gameState.adjustBreaks(team: "a", delta: -1) },
                                  inc: { gameState.adjustBreaks(team: "a", delta: 1) })
                        adjustRow(dot: YASAColor.teamB, name: gameState.teamBName, value: gameState.breaksB,
                                  dec: { gameState.adjustBreaks(team: "b", delta: -1) },
                                  inc: { gameState.adjustBreaks(team: "b", delta: 1) })
                    }
                    .background(YASAColor.cardFill)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // PULLING NOW
                VStack(alignment: .leading, spacing: 11) {
                    Text("PULLING NOW").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(1.4).foregroundColor(YASAColor.textMuted)
                    HStack(spacing: 11) {
                        pullSegment(title: gameState.teamAName, isSelected: gameState.pullingTeam == "a",
                                    fill: YASAColor.teamA, lip: YASAColor.teamALip) {
                            gameState.setPullingOverride(team: "a")
                        }
                        pullSegment(title: gameState.teamBName, isSelected: gameState.pullingTeam == "b",
                                    fill: YASAColor.teamB, lip: YASAColor.teamBLip) {
                            gameState.setPullingOverride(team: "b")
                        }
                    }
                }

                // RATIO
                VStack(alignment: .leading, spacing: 11) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("RATIO").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(1.4).foregroundColor(YASAColor.textMuted)
                        Text("tap to set current").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(YASAColor.textFaint)
                    }
                    HStack(spacing: 9) {
                        ForEach(Array(gameState.rotationCycle.enumerated()), id: \.offset) { index, label in
                            Button { gameState.setRatioIndex(index) } label: {
                                Text(label)
                                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                                    .foregroundColor(index == gameState.rotationIndex ? .black : Color(white: 0.53))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(FlatChipButtonStyle(
                                fill: index == gameState.rotationIndex ? YASAColor.teamA : YASAColor.inactiveSegment
                            ))
                        }
                    }
                }

                // ROSTER
                if gameState.useLineRolling {
                    VStack(alignment: .leading, spacing: 11) {
                        Text("ROSTER").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(1.4).foregroundColor(YASAColor.textMuted)
                        VStack(spacing: 0) {
                            rosterRow(title: "Open players", value: $gameState.openCount, divider: true)
                            rosterRow(title: "FMP players", value: $gameState.fmpCount, divider: false)
                        }
                        .background(YASAColor.cardFill)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                // Actions
                VStack(spacing: 13) {
                    Button {
                        gameState.undo()
                    } label: {
                        Text("↺  Undo Last Point")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundColor(gameState.canUndo() ? .white : YASAColor.disabled)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: Color(white: 0.114), lip: .black, radius: 15))
                    .disabled(!gameState.canUndo())

                    Button {
                        gameState.finishGame()
                    } label: {
                        Text("Finish Game")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip, radius: 15))

                    Button {
                        showResetConfirmation = true
                    } label: {
                        Text("Reset Game")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.teamB, lip: YASAColor.teamBLip, radius: 15))
                }
                .padding(.top, 2)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
        }
        .background(YASAColor.surfaceBlack)
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

    // MARK: - Rows

    private func subheader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(1.8)
            .foregroundColor(YASAColor.textFaint)
            .padding(.horizontal, 16)
            .padding(.top, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func adjustRow(dot: Color, name: String, value: Int, dec: @escaping () -> Void, inc: @escaping () -> Void, divider: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 10) {
                    Circle().fill(dot).frame(width: 11, height: 11)
                    Text(name)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                Spacer()
                HStack(spacing: 13) {
                    Button(action: dec) {
                        Text("–").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                            .frame(width: 34, height: 34)
                    }.buttonStyle(CircleControlButtonStyle())
                    Text("\(value)")
                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(minWidth: 24)
                    Button(action: inc) {
                        Text("+").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                            .frame(width: 34, height: 34)
                    }.buttonStyle(CircleControlButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            if divider {
                Rectangle().fill(YASAColor.divider).frame(height: 1).padding(.horizontal, 16)
            }
        }
    }

    private func rosterRow(title: String, value: Binding<Int>, divider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundColor(.white)
                Spacer()
                HStack(spacing: 13) {
                    Button { if value.wrappedValue > 1 { value.wrappedValue -= 1 } } label: {
                        Text("–").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                            .frame(width: 34, height: 34)
                    }.buttonStyle(CircleControlButtonStyle())
                    Text("\(value.wrappedValue)")
                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(minWidth: 24)
                    Button { value.wrappedValue += 1 } label: {
                        Text("+").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                            .frame(width: 34, height: 34)
                    }.buttonStyle(CircleControlButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            if divider {
                Rectangle().fill(YASAColor.divider).frame(height: 1).padding(.horizontal, 16)
            }
        }
    }

    private func pullSegment(title: String, isSelected: Bool, fill: Color, lip: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(isSelected ? .black : YASAColor.textDim)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
        }
        .buttonStyle(ChunkyCapsuleButtonStyle(
            fill: isSelected ? fill : YASAColor.inactiveSegment,
            lip: isSelected ? lip : .black,
            radius: 13
        ))
    }
}

/// Flat (no-lip) chip button used for the ratio rotation chips.
struct FlatChipButtonStyle: ButtonStyle {
    var fill: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(RoundedRectangle(cornerRadius: 11).fill(fill))
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ControlsView(gameState: GameState(), showControls: .constant(true))
}
