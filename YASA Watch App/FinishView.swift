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

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ScorecardView(summary: gameState.makeSummary())
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(action: saveToPhone) {
                    Label(buttonTitle, systemImage: "iphone.and.arrow.forward")
                }
                .buttonStyle(.borderedProminent)

                if status == .failed {
                    Text("Couldn't create the image. Try again.")
                        .font(.caption2).foregroundStyle(.red)
                }

                Button("New Game") { gameState.resetGame() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }

    private var buttonTitle: String { status == .sent ? "Sent to iPhone" : "Save to Phone" }

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
