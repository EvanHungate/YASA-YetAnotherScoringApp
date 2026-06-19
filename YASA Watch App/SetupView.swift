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
            VStack(alignment: .leading, spacing: 12) {
                Text("New Game")
                    .font(YASAFont.display(17))
                    .foregroundColor(.white)
                    .padding(.top, 2)

                teamNameField(name: "Team A", text: $gameState.teamAName, dot: YASAColor.teamA)
                teamNameField(name: "Team B", text: $gameState.teamBName, dot: YASAColor.teamB)

                sectionLabel("WHO PULLS FIRST?")
                HStack(spacing: 6) {
                    segmentButton(title: gameState.teamAName, isSelected: gameState.initialPuller == "a") {
                        gameState.initialPuller = "a"
                    }
                    segmentButton(title: gameState.teamBName, isSelected: gameState.initialPuller == "b") {
                        gameState.initialPuller = "b"
                    }
                }

                sectionLabel("STARTING RATIO")
                HStack(spacing: 6) {
                    segmentButton(title: "Open", isSelected: gameState.rotationStart == "O") {
                        gameState.rotationStart = "O"
                    }
                    segmentButton(title: "FMP", isSelected: gameState.rotationStart == "F") {
                        gameState.rotationStart = "F"
                    }
                }

                sectionLabel("GAME TO")
                stepperRow(value: $gameState.targetPoints, range: 1...30)

                HStack {
                    Text("Line Roll")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $gameState.useLineRolling)
                        .labelsHidden()
                        .tint(YASAColor.primary)
                }
                .padding(.top, 2)

                if gameState.useLineRolling {
                    sectionLabel("OPEN PLAYERS")
                    stepperRow(value: $gameState.openCount, range: 1...14)

                    sectionLabel("FMP PLAYERS")
                    stepperRow(value: $gameState.fmpCount, range: 1...14)
                }

                Button {
                    gameState.startGame()
                } label: {
                    Text("Start Game")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip))
                .padding(.top, 4)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(YASAColor.screenBlack)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .tracking(1)
            .foregroundColor(YASAColor.textMuted)
            .padding(.top, 4)
    }

    private func teamNameField(name: String, text: Binding<String>, dot: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(dot).frame(width: 8, height: 8)
            TextField(name, text: text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(YASAColor.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }

    private func segmentButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(isSelected ? .black : YASAColor.textDim)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(FlatChipButtonStyle(fill: isSelected ? YASAColor.teamA : YASAColor.inactiveSegment))
    }

    private func stepperRow(value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack(spacing: 10) {
            Button {
                if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
            } label: {
                Text("–").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                    .frame(width: 26, height: 26)
            }.buttonStyle(CircleControlButtonStyle())

            Text("\(value.wrappedValue)")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .frame(minWidth: 22)

            Button {
                if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
            } label: {
                Text("+").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                    .frame(width: 26, height: 26)
            }.buttonStyle(CircleControlButtonStyle())
        }
    }
}

#Preview {
    SetupView(gameState: GameState())
}
