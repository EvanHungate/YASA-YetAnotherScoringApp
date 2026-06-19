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
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("New Game")
                        .font(YASAFont.display(34))
                        .foregroundColor(.white)
                    Text("Set up the match")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if connectivity.isActivated {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(connectivity.isReachable ? YASAColor.connectionDot : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(connectivity.isReachable ? "Watch Connected" : "Watch Paired")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(white: 0.6))
                    }
                }

                sectionHeader("TEAMS")
                VStack(spacing: 11) {
                    teamNameRow(dot: YASAColor.teamA, text: $gameState.teamAName, placeholder: "Team A")
                    teamNameRow(dot: YASAColor.teamB, text: $gameState.teamBName, placeholder: "Team B")
                }

                sectionHeader("WHO PULLS FIRST?")
                HStack(spacing: 11) {
                    segmentButton(
                        title: gameState.teamAName.isEmpty ? "Team A" : gameState.teamAName,
                        isSelected: gameState.initialPuller == "a",
                        selectedFill: YASAColor.teamA, selectedLip: YASAColor.teamALip
                    ) {
                        gameState.initialPuller = "a"
                        gameState.pullingTeam = "a"
                    }
                    segmentButton(
                        title: gameState.teamBName.isEmpty ? "Team B" : gameState.teamBName,
                        isSelected: gameState.initialPuller == "b",
                        selectedFill: YASAColor.teamB, selectedLip: YASAColor.teamBLip
                    ) {
                        gameState.initialPuller = "b"
                        gameState.pullingTeam = "b"
                    }
                }

                sectionHeader("STARTING RATIO")
                HStack(spacing: 11) {
                    segmentButton(title: "Open 4:3", isSelected: gameState.rotationStart == "O",
                                  selectedFill: YASAColor.primary, selectedLip: YASAColor.primaryLip) {
                        gameState.rotationStart = "O"
                    }
                    segmentButton(title: "FMP 4:3", isSelected: gameState.rotationStart == "F",
                                  selectedFill: YASAColor.primary, selectedLip: YASAColor.primaryLip) {
                        gameState.rotationStart = "F"
                    }
                }

                sectionHeader("GAME TO")
                HStack {
                    Text("Points to win")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(white: 0.78))
                    Spacer()
                    stepperRow(value: $gameState.targetPoints, minimum: 1, circleSize: 40, valueSize: 26)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(rowBackground())

                VStack(spacing: 14) {
                    HStack {
                        Text("Track Line Roll")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        lineRollToggle
                    }

                    if gameState.useLineRolling {
                        VStack(spacing: 14) {
                            HStack {
                                Text("Open players")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(white: 0.78))
                                Spacer()
                                stepperRow(value: $gameState.openCount, minimum: 1, circleSize: 36, valueSize: 22)
                            }
                            HStack {
                                Text("FMP players")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(white: 0.78))
                                Spacer()
                                stepperRow(value: $gameState.fmpCount, minimum: 1, circleSize: 36, valueSize: 22)
                            }
                        }
                        .padding(16)
                        .background(Color(white: 0.067))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                Button {
                    gameState.startGame()
                } label: {
                    Text("Start Game")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                }
                .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip))
                .shadow(color: YASAColor.primary.opacity(0.32), radius: 18, y: 7)
                .padding(.top, 4)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 22)
            .padding(.top, 16)
        }
        .background(YASAColor.surfaceBlack)
    }

    // MARK: - Subviews

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.4)
            .foregroundColor(YASAColor.textMuted)
    }

    private func rowBackground() -> some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(YASAColor.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black)
                    .frame(height: 5)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            )
    }

    private func teamNameRow(dot: Color, text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 13) {
            Circle().fill(dot).frame(width: 12, height: 12)
            TextField(placeholder, text: text)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(rowBackground())
    }

    private func segmentButton(title: String, isSelected: Bool, selectedFill: Color, selectedLip: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(isSelected ? .black : YASAColor.textDim)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(ChunkyCapsuleButtonStyle(
            fill: isSelected ? selectedFill : YASAColor.inactiveSegment,
            lip: isSelected ? selectedLip : .black,
            radius: 14
        ))
    }

    private func stepperRow(value: Binding<Int>, minimum: Int, circleSize: CGFloat, valueSize: CGFloat) -> some View {
        HStack(spacing: 16) {
            Button { if value.wrappedValue > minimum { value.wrappedValue -= 1 } } label: {
                Text("–")
                    .font(.system(size: valueSize - 2, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: circleSize, height: circleSize)
            }
            .buttonStyle(CircleControlButtonStyle())

            Text("\(value.wrappedValue)")
                .font(.system(size: valueSize, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .frame(minWidth: valueSize + 12)

            Button { value.wrappedValue += 1 } label: {
                Text("+")
                    .font(.system(size: valueSize - 2, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: circleSize, height: circleSize)
            }
            .buttonStyle(CircleControlButtonStyle())
        }
    }

    private var lineRollToggle: some View {
        Button {
            gameState.useLineRolling.toggle()
        } label: {
            ZStack(alignment: gameState.useLineRolling ? .trailing : .leading) {
                Capsule()
                    .fill(gameState.useLineRolling ? YASAColor.primary : Color(white: 0.2))
                    .frame(width: 58, height: 33)
                Circle()
                    .fill(Color.white)
                    .frame(width: 27, height: 27)
                    .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                    .padding(.horizontal, 3)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: gameState.useLineRolling)
    }
}

/// A small round +/− control button (#262626 fill) that scales down on press.
struct CircleControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Circle().fill(YASAColor.controlFill))
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    SetupView(gameState: GameState())
}
