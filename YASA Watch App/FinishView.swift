//
//  FinishView.swift
//  YASA Watch App
//
//  End-of-game screen: shows the scorecard, sends it to the iPhone to save in Photos,
//  and starts a new game.
//

import SwiftUI

struct FinishView: View {
    @ObservedObject var gameState: GameState
    @State private var status: SaveStatus = .idle

    enum SaveStatus { case idle, sent, failed }

    private var aWon: Bool { gameState.winningTeam == "a" }
    private var winnerName: String { aWon ? gameState.teamAName : gameState.teamBName }
    private var winColor: Color { aWon ? YASAColor.teamA : YASAColor.teamB }
    private var winLip: Color { aWon ? YASAColor.teamALip : YASAColor.teamBLip }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("FINAL")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(YASAColor.textMuted)
                    .padding(.top, 2)

                Text(winnerName)
                    .font(YASAFont.display(22))
                    .foregroundColor(winColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)

                Text("WINS")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(1.6)
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 9).fill(winLip)
                            RoundedRectangle(cornerRadius: 9).fill(winColor).padding(.bottom, 3)
                        }
                    )

                Text("\(gameState.scoreA) – \(gameState.scoreB)")
                    .font(YASAFont.display(34))
                    .foregroundColor(.white)
                    .padding(.top, 2)

                HStack(spacing: 8) {
                    statTile(label: "TIME", value: gameState.formattedDuration())
                    statTile(label: "BREAKS", value: "\(gameState.breaksA) – \(gameState.breaksB)")
                }

                VStack(spacing: 8) {
                    Button {
                        gameState.resetGame()
                    } label: {
                        Text("New Game")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip))

                    Button(action: saveToPhone) {
                        Text(buttonTitle)
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: Color(white: 0.114), lip: .black))

                    if status == .failed {
                        Text("Couldn't create the image. Try again.")
                            .font(.system(size: 9))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(YASAColor.surfaceBlack)
        .preferredColorScheme(.dark)
    }

    private var buttonTitle: String { status == .sent ? "Sent to iPhone" : "Save to Phone" }

    private func statTile(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .tracking(0.6)
                .foregroundColor(YASAColor.textDim)
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 10).fill(YASAColor.cardFill))
    }

    private func saveToPhone() {
        let summary = gameState.makeSummary()
        if let url = ScorecardRenderer.renderPNG(summary) {
            WatchConnectivityManager.shared.sendScorecard(fileURL: url)
            status = .sent
        } else {
            status = .failed
        }
    }
}

#Preview {
    let gs = GameState()
    gs.gameStarted = true
    gs.scoreA = 15; gs.scoreB = 12; gs.breaksA = 3; gs.breaksB = 1
    gs.totalPoints = 27; gs.winningTeam = "a"
    return FinishView(gameState: gs)
}
