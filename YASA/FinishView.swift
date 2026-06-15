//
//  FinishView.swift
//  YASA
//
//  End-of-game screen: shows the scorecard, saves it directly to Photos, and starts a new game.
//

import SwiftUI

struct FinishView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject private var connectivity = PhoneConnectivityManager.shared
    @Environment(\.displayScale) private var displayScale
    @State private var status: SaveStatus = .idle

    enum SaveStatus: Equatable { case idle, saving, saved, failed(String) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScorecardView(summary: gameState.makeSummary())
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Button(action: saveToPhotos) {
                    Label(buttonTitle, systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                .disabled(status == .saving)

                if case let .failed(message) = status {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button("New Game") { gameState.resetGame() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
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
        default: return "Save to Photos"
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
}

#Preview {
    let gs = GameState()
    gs.gameStarted = true
    gs.scoreA = 15; gs.scoreB = 12; gs.breaksA = 3; gs.breaksB = 1
    gs.totalPoints = 27; gs.winningTeam = "a"
    return FinishView(gameState: gs)
}
