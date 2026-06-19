//
//  GameView.swift
//  YASA Watch App
//
//  Main game screen with scoring buttons
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    RatioRollText(label: gameState.currentRatioLabel(), size: 12, color: .white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.13))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    Spacer()
                }
                .padding(.top, 4)
                .padding(.bottom, 3)

                HStack(spacing: 5) {
                    teamBlock(team: "a", name: gameState.teamAName, score: gameState.scoreA,
                              breaks: gameState.breaksA, isPulling: gameState.pullingTeam == "a",
                              fill: YASAColor.teamA, lip: YASAColor.teamALip,
                              breakTrigger: gameState.breakTriggerA, showLineRoll: true)
                    teamBlock(team: "b", name: gameState.teamBName, score: gameState.scoreB,
                              breaks: gameState.breaksB, isPulling: gameState.pullingTeam == "b",
                              fill: YASAColor.teamB, lip: YASAColor.teamBLip,
                              breakTrigger: gameState.breakTriggerB, showLineRoll: false)
                }
                .padding(.horizontal, 6)
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

    @ViewBuilder
    private func teamBlock(
        team: String, name: String, score: Int, breaks: Int,
        isPulling: Bool, fill: Color, lip: Color, breakTrigger: Int, showLineRoll: Bool
    ) -> some View {
        Button {
            gameState.score(team: team)
        } label: {
            VStack(spacing: 0) {
                HStack {
                    Text(name)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: 46, alignment: .leading)
                    Spacer()
                    Text(isPulling ? "P" : "R")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 8)
                .padding(.top, 7)

                Spacer(minLength: 0)
                ZStack {
                    ScorePopText(value: score, size: 52, color: .black)
                    BreakCelebrationView(trigger: breakTrigger, big: false)
                }
                Spacer(minLength: 0)

                if showLineRoll && gameState.useLineRolling {
                    lineRollLabel(prefix: "F", numbers: gameState.currentFmpNumbers())
                    lineRollLabel(prefix: "O", numbers: gameState.currentOpenNumbers())
                }

                Text("B \(breaks)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.6))
                    .padding(.bottom, 7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 182)
            .background(fill)
            .overlay(
                Rectangle().fill(lip).frame(height: 6)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressDownButtonStyle())
    }

    private func lineRollLabel(prefix: String, numbers: [Int]) -> some View {
        Text(numbers.isEmpty ? "" : "\(prefix) \(numbers.map(String.init).joined(separator: " "))")
            .font(.system(size: 8, weight: .heavy, design: .rounded))
            .tracking(0.4)
            .foregroundColor(.black)
            .frame(height: 9)
    }

    private var halftimeOverlay: some View {
        VStack(spacing: 7) {
            Text("HALFTIME")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(2.2)
                .foregroundColor(Color(white: 0.48))
            Text("\(gameState.scoreA) – \(gameState.scoreB)")
                .font(YASAFont.display(38))
                .foregroundColor(.white)
            Text("\(nextPullerName) pulls next")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.604, green: 0.584, blue: 0.549))
            Button {
                gameState.continueFromHalftime()
            } label: {
                Text("Start 2nd Half")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
            }
            .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip))
            .padding(.top, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(YASAColor.surfaceBlack)
        .transition(.opacity)
    }

    private var nextPullerName: String {
        gameState.initialPuller == "a" ? gameState.teamBName : gameState.teamAName
    }
}

#Preview {
    let gameState = GameState()
    gameState.gameStarted = true
    gameState.rotationCycle = ["O2", "F1", "F2", "O1"]
    return GameView(gameState: gameState)
}
