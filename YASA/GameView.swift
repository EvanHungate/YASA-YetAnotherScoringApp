//
//  GameView.swift
//  YASA
//
//  Main game screen with scoring buttons
//

import SwiftUI

private let teamPalette: [Color] = [
    Color(red: 0.30, green: 0.70, blue: 0.65), // teal
    Color(red: 1.00, green: 0.70, blue: 0.50), // salmon
    Color(red: 0.40, green: 0.70, blue: 1.00), // sky blue
    Color(red: 0.70, green: 0.50, blue: 1.00), // soft purple
    Color(red: 0.60, green: 0.90, blue: 0.40), // lime
    Color(red: 1.00, green: 0.85, blue: 0.30), // gold
    Color(red: 1.00, green: 0.45, blue: 0.45), // coral
    Color(red: 0.60, green: 0.60, blue: 1.00), // periwinkle
]

private func pickTwoColors() -> (Color, Color) {
    let shuffled = teamPalette.shuffled()
    return (shuffled[0], shuffled[1])
}

struct GameView: View {
    @ObservedObject var gameState: GameState
    @Binding var showControls: Bool
    @ObservedObject private var connectivity = PhoneConnectivityManager.shared

    @State private var colorA: Color = teamPalette[0]
    @State private var colorB: Color = teamPalette[1]

    @State private var flashA: Double = 0.18
    @State private var flashB: Double = 0.18
    @State private var sweepA: CGFloat = 1
    @State private var sweepB: CGFloat = 1

    @State private var winScale: CGFloat = 0
    @State private var winOpacity: Double = 0
    @State private var winColor: Color = .clear

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header strip
                HStack {
                    Spacer()
                    Circle()
                        .fill(connectivity.isReachable ? colorA : Color(white: 0.4))
                        .frame(width: 8, height: 8)
                    Text(connectivity.isReachable ? "Watch" : "Offline")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))

                // Team A — top half
                scoreButton(
                    team: "a",
                    name: gameState.teamAName,
                    score: gameState.scoreA,
                    breaks: gameState.breaksA,
                    isPulling: gameState.pullingTeam == "a",
                    borderColor: colorA,
                    flashIntensity: flashA,
                    sweepOffset: sweepA,
                    ratioLabel: gameState.currentRatioLabel()
                )

                // Team B — bottom half
                scoreButton(
                    team: "b",
                    name: gameState.teamBName,
                    score: gameState.scoreB,
                    breaks: gameState.breaksB,
                    isPulling: gameState.pullingTeam == "b",
                    borderColor: colorB,
                    flashIntensity: flashB,
                    sweepOffset: sweepB,
                    ratioLabel: nil
                )

                // Controls button
                Button { showControls = true } label: {
                    Text("Controls")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(white: 0.12))
                }
            }
            .background(Color.black)

            Circle()
                .fill(winColor.opacity(winOpacity))
                .scaleEffect(winScale)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear {
            let (a, b) = pickTwoColors()
            colorA = a; colorB = b
        }
        .onChange(of: gameState.scoreA) { _, _ in triggerScoreFlash(isA: true) }
        .onChange(of: gameState.scoreB) { _, _ in triggerScoreFlash(isA: false) }
        .onChange(of: gameState.showWinnerModal) { _, showing in
            if showing { triggerWinFlash() }
        }
        .alert("Halftime", isPresented: $gameState.showHalftimeModal) {
            Button("Continue") { gameState.continueFromHalftime() }
        } message: {
            Text("8 points reached. Switching sides.")
        }
        .sheet(isPresented: $gameState.showWinnerModal) {
            FinishView(gameState: gameState)
                .interactiveDismissDisabled(true)
        }
    }

    // MARK: - Animations

    private func triggerScoreFlash(isA: Bool) {
        withAnimation(.easeOut(duration: 0.12)) {
            if isA { flashA = 0.6 } else { flashB = 0.6 }
        }
        withAnimation(.easeIn(duration: 0.55).delay(0.12)) {
            if isA { flashA = 0.18 } else { flashB = 0.18 }
        }
        if isA { sweepA = 1 } else { sweepB = 1 }
        withAnimation(.easeOut(duration: 0.5)) {
            if isA { sweepA = -1 } else { sweepB = -1 }
        }
    }

    private func triggerWinFlash() {
        winColor = gameState.winningTeam == "a" ? colorA : colorB
        winScale = 0
        withAnimation(.easeOut(duration: 0.7)) { winScale = 6 }
        withAnimation(.linear(duration: 0.15)) { winOpacity = 0.55 }
        withAnimation(.easeIn(duration: 0.5).delay(0.4)) { winOpacity = 0 }
    }

    // MARK: - Button

    @ViewBuilder
    private func scoreButton(
        team: String, name: String, score: Int, breaks: Int,
        isPulling: Bool, borderColor: Color,
        flashIntensity: Double, sweepOffset: CGFloat,
        ratioLabel: String?
    ) -> some View {
        Button { gameState.score(team: team) } label: {
            ZStack {
                // Top-left: team name + ratio (if top button) + breaks
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    if let ratio = ratioLabel {
                        Text(ratio)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(borderColor)
                    }
                    Spacer()
                    Text("\(breaks) break\(breaks == 1 ? "" : "s")")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 20)
                .padding(.top, 18)
                .padding(.bottom, 18)

                // Top-right: P/R badge
                Text(isPulling ? "P" : "R")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(borderColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, 20)
                    .padding(.top, 18)

                // Center: score
                Text("\(score)")
                    .font(.system(size: 90, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [.black, borderColor.opacity(flashIntensity)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    LinearGradient(
                        colors: [.clear, borderColor.opacity(0.45), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .offset(y: sweepOffset * 300)
                    .clipped()
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor.opacity(0.8), lineWidth: 3)
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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
