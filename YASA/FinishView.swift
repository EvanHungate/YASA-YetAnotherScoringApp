//
//  FinishView.swift
//  YASA
//
//  End-of-game screen: winner banner, final scores, stat tiles, save-to-Photos, and new game.
//

import SwiftUI

struct FinishView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject private var connectivity = PhoneConnectivityManager.shared
    @Environment(\.displayScale) private var displayScale
    @State private var status: SaveStatus = .idle

    enum SaveStatus: Equatable { case idle, saving, saved, failed(String) }

    private var aWon: Bool { gameState.winningTeam == "a" }
    private var winnerName: String { aWon ? gameState.teamAName : gameState.teamBName }
    private var winColor: Color { aWon ? YASAColor.teamA : YASAColor.teamB }
    private var winLip: Color { aWon ? YASAColor.teamALip : YASAColor.teamBLip }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 18) {
                    Text(winnerName)
                        .font(YASAFont.display(64))
                        .foregroundColor(winColor)
                        .multilineTextAlignment(.center)

                    Text("WINS")
                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.black)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 11)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 13).fill(winLip)
                                RoundedRectangle(cornerRadius: 13).fill(winColor).padding(.bottom, 6)
                            }
                        )
                }

                HStack(spacing: 20) {
                    finalScoreColumn(name: gameState.teamAName, score: gameState.scoreA, breaks: gameState.breaksA, won: aWon)
                    Text("–")
                        .font(YASAFont.display(28))
                        .foregroundColor(Color(white: 0.29))
                    finalScoreColumn(name: gameState.teamBName, score: gameState.scoreB, breaks: gameState.breaksB, won: !aWon)
                }

                HStack(spacing: 11) {
                    statTile(label: "TIME", value: gameState.formattedDuration())
                    statTile(label: "POINTS", value: "\(gameState.totalPoints)")
                    statTile(label: "BREAKS", value: "\(gameState.breaksA) – \(gameState.breaksB)")
                }

                VStack(spacing: 12) {
                    Button {
                        gameState.resetGame()
                    } label: {
                        Text("New Game")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: YASAColor.primary, lip: YASAColor.primaryLip))
                    .shadow(color: YASAColor.primary.opacity(0.3), radius: 16, y: 7)

                    Button(action: saveToPhotos) {
                        Text(buttonTitle)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(ChunkyCapsuleButtonStyle(fill: Color(white: 0.114), lip: .black, radius: 14))
                    .disabled(status == .saving)

                    if case let .failed(message) = status {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 34)
        }
        .background(YASAColor.surfaceBlack)
        .preferredColorScheme(.dark)
        .onChange(of: connectivity.lastSavedDate) { _, _ in
            if status == .saving { status = .saved }
        }
        .onChange(of: connectivity.lastError) { _, newValue in
            if status == .saving, let message = newValue { status = .failed(message) }
        }
    }

    private var buttonTitle: String {
        switch status {
        case .saved: return "Saved to Photos"
        case .saving: return "Saving…"
        default: return "Save Scorecard"
        }
    }

    private func saveToPhotos() {
        guard let url = ScorecardRenderer.renderPNG(gameState.makeSummary(), scale: displayScale) else {
            status = .failed("Couldn't create the image.")
            return
        }
        status = .saving
        connectivity.saveScorecard(imageFileURL: url)
    }

    private func finalScoreColumn(name: String, score: Int, breaks: Int, won: Bool) -> some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(won ? .white : Color(white: 0.373))
                .lineLimit(1)
            Text("\(score)")
                .font(YASAFont.display(58))
                .foregroundColor(won ? .white : Color(white: 0.353))
            Text("\(breaks) brk")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(YASAColor.textDim)
        }
        .frame(maxWidth: .infinity)
    }

    private func statTile(label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundColor(YASAColor.textDim)
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 14).fill(YASAColor.cardFill))
    }
}

#Preview {
    let gs = GameState()
    gs.gameStarted = true
    gs.scoreA = 15; gs.scoreB = 12; gs.breaksA = 3; gs.breaksB = 1
    gs.totalPoints = 27; gs.winningTeam = "a"
    return FinishView(gameState: gs)
}
