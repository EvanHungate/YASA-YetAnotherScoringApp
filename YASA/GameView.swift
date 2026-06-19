//
//  GameView.swift
//  YASA
//
//  Main game screen with scoring buttons
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @Binding var showControls: Bool
    @ObservedObject private var connectivity = PhoneConnectivityManager.shared

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Status row
                HStack(spacing: 6) {
                    Spacer()
                    Circle()
                        .fill(connectivity.isReachable ? YASAColor.connectionDot : Color(white: 0.4))
                        .frame(width: 7, height: 7)
                        .shadow(color: connectivity.isReachable ? YASAColor.connectionDot.opacity(0.8) : .clear, radius: 4)
                    Text(connectivity.isReachable ? "WATCH" : "OFFLINE")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(white: 0.81))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                teamBlock(team: "a", name: gameState.teamAName, score: gameState.scoreA,
                          breaks: gameState.breaksA, isPulling: gameState.pullingTeam == "a",
                          fill: YASAColor.teamA, lip: YASAColor.teamALip,
                          breakTrigger: gameState.breakTriggerA,
                          showLineRoll: true)
                    .padding(.horizontal, 9)
                    .padding(.top, 6)

                // Middle strip: ratio · menu · total points
                HStack {
                    RatioRollText(label: gameState.currentRatioLabel(), size: 26, color: .white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button { showControls = true } label: {
                        VStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { _ in
                                Capsule().fill(Color.white).frame(width: 18, height: 2.5)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(YASAColor.cardFill))
                        .overlay(Circle().stroke(Color(white: 0.2), lineWidth: 2))
                        .shadow(color: .black.opacity(0.45), radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(gameState.totalPoints)")
                            .font(YASAFont.display(26))
                            .foregroundColor(.white)
                        Text("PTS")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                teamBlock(team: "b", name: gameState.teamBName, score: gameState.scoreB,
                          breaks: gameState.breaksB, isPulling: gameState.pullingTeam == "b",
                          fill: YASAColor.teamB, lip: YASAColor.teamBLip,
                          breakTrigger: gameState.breakTriggerB,
                          showLineRoll: false)
                    .padding(.horizontal, 9)
                    .padding(.bottom, 6)
            }
            .background(YASAColor.screenBlack)

            if gameState.showHalftimeModal {
                halftimeOverlay
            }
        }
        .sheet(isPresented: $gameState.showWinnerModal) {
            FinishView(gameState: gameState)
                .interactiveDismissDisabled(true)
        }
    }

    // MARK: - Team block

    @ViewBuilder
    private func teamBlock(
        team: String, name: String, score: Int, breaks: Int,
        isPulling: Bool, fill: Color, lip: Color, breakTrigger: Int, showLineRoll: Bool
    ) -> some View {
        Button {
            gameState.score(team: team)
        } label: {
            GeometryReader { _ in
                ZStack {
                    VStack {
                        HStack(alignment: .top) {
                            Text(name)
                                .font(.system(size: 19, weight: .heavy, design: .rounded))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Spacer()
                            Text(isPulling ? "PULLING" : "RECEIVING")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .tracking(0.6)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    ScorePopText(value: score, size: 132, color: .black)

                    VStack {
                        Spacer()
                        HStack {
                            if showLineRoll && gameState.useLineRolling {
                                VStack(alignment: .center, spacing: 6) {
                                    lineRow(prefix: "O", numbers: gameState.currentOpenNumbers())
                                    lineRow(prefix: "F", numbers: gameState.currentFmpNumbers())
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 6)
                            }
                        }
                        HStack {
                            Text("\(breaks) BREAK\(breaks == 1 ? "" : "S")")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .tracking(0.6)
                                .foregroundColor(.black.opacity(0.62))
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    BreakCelebrationView(trigger: breakTrigger, big: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(fill)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .fill(lip)
                    .frame(height: 9)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.28), radius: 16, y: 7)
        }
        .buttonStyle(PressDownButtonStyle())
    }

    @ViewBuilder
    private func lineRow(prefix: String, numbers: [Int]) -> some View {
        if !numbers.isEmpty {
            HStack(spacing: 9) {
                Text(prefix)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.8)
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                Text(numbers.map(String.init).joined(separator: " "))
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .tracking(2.6)
                    .foregroundColor(.black)
            }
        }
    }

    // MARK: - Halftime overlay

    private var halftimeOverlay: some View {
        VStack(spacing: 22) {
            Text("HALFTIME")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .tracking(5)
                .foregroundColor(Color(white: 0.48))
            Text("\(gameState.scoreA) – \(gameState.scoreB)")
                .font(YASAFont.display(70))
                .foregroundColor(.white)
            Text("\(nextPullerName) pulls to start\nthe second half")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.604, green: 0.584, blue: 0.549))

            Button {
                gameState.continueFromHalftime()
            } label: {
                Text("Start Second Half")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 18)
            }
            .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip))
            .shadow(color: YASAColor.primary.opacity(0.3), radius: 16, y: 7)
            .padding(.top, 6)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(YASAColor.surfaceBlack)
        .transition(.opacity)
    }

    private var nextPullerName: String {
        gameState.initialPuller == "a" ? gameState.teamBName : gameState.teamAName
    }
}

/// Translates the block down on press to compress its bottom "lip".
struct PressDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 6 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// A pill-shaped chunky button (used for primary actions like "Start Second Half").
struct ChunkyCapsuleButtonStyle: ButtonStyle {
    var fill: Color
    var lip: Color
    var radius: CGFloat = 16
    var lipHeight: CGFloat = 6

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: radius).fill(lip)
                    RoundedRectangle(cornerRadius: radius)
                        .fill(fill)
                        .padding(.bottom, configuration.isPressed ? 0 : lipHeight)
                }
            )
            .offset(y: configuration.isPressed ? lipHeight : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    let gs = GameState()
    gs.gameStarted = true
    gs.teamAName = "Hawks"
    gs.teamBName = "Eagles"
    gs.scoreA = 7; gs.scoreB = 5
    gs.breaksA = 2; gs.breaksB = 1
    gs.rotationCycle = ["O2", "F1", "F2", "O1"]
    return GameView(gameState: gs, showControls: .constant(false))
}
