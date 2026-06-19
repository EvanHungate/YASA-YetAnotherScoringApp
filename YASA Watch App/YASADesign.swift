//
//  YASADesign.swift
//  YASA Watch App
//
//  Shared design tokens for the "life-counter" scoring UI redesign.
//

import SwiftUI

enum YASAColor {
    static let teamA = Color(red: 1.00, green: 0.769, blue: 0.0)        // #FFC400
    static let teamALip = Color(red: 0.824, green: 0.624, blue: 0.0)    // #D29F00
    static let teamB = Color(red: 1.00, green: 0.231, blue: 0.361)      // #FF3B5C
    static let teamBLip = Color(red: 0.820, green: 0.122, blue: 0.243)  // #D11F3E
    static let primary = Color(red: 0.184, green: 0.420, blue: 1.0)     // #2F6BFF
    static let primaryLip = Color(red: 0.118, green: 0.286, blue: 0.753) // #1E49C0
    static let connectionDot = Color(red: 0.204, green: 0.827, blue: 0.604) // #34D39A
    static let screenBlack = Color.black
    static let surfaceBlack = Color(red: 0.039, green: 0.039, blue: 0.039) // #0A0A0A
    static let cardFill = Color(red: 0.086, green: 0.086, blue: 0.086)     // #161616
    static let controlFill = Color(red: 0.165, green: 0.165, blue: 0.165)  // #2A2A2A
    static let inactiveSegment = Color(red: 0.094, green: 0.094, blue: 0.094) // #181818
    static let divider = Color(red: 0.149, green: 0.149, blue: 0.149)      // #262626
    static let textMuted = Color(red: 0.561, green: 0.561, blue: 0.561)    // #8F8F8F
    static let textDim = Color(red: 0.545, green: 0.545, blue: 0.545)      // #8A8A8A
    static let disabled = Color(red: 0.333, green: 0.333, blue: 0.333)     // #555555
}

enum YASAFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// Score number that "pops" whenever its value changes.
struct ScorePopText: View {
    let value: Int
    let size: CGFloat
    let color: Color

    @State private var scale: CGFloat = 1

    var body: some View {
        Text("\(value)")
            .font(YASAFont.display(size))
            .foregroundColor(color)
            .monospacedDigit()
            .scaleEffect(scale)
            .onChange(of: value) { _, _ in
                scale = 0.55
                withAnimation(.interpolatingSpring(stiffness: 230, damping: 14)) {
                    scale = 1.0
                }
            }
    }
}

/// Rolls a label up from below on change, matching the ratio readout motion.
struct RatioRollText: View {
    let label: String
    let size: CGFloat
    let color: Color

    var body: some View {
        Text(label)
            .font(YASAFont.display(size))
            .foregroundColor(color)
            .id(label)
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .opacity
            ))
            .animation(.timingCurve(0.3, 1.35, 0.5, 1, duration: 0.42), value: label)
    }
}

/// The "BREAK" celebration: white flash, flying diamond shards, a shake, and a slamming badge.
struct BreakCelebrationView: View {
    var trigger: Int
    var big: Bool

    @State private var flashOpacity: Double = 0
    @State private var badgeScale: CGFloat = 1.8
    @State private var badgeOpacity: Double = 0
    @State private var shardProgress: CGFloat = 0
    @State private var shakeOffset: CGFloat = 0

    private var shardCount: Int { big ? 12 : 8 }
    private var shardSize: CGFloat { big ? 14 : 8 }
    private var badgeSize: CGFloat { big ? 46 : 17 }

    var body: some View {
        ZStack {
            Color.white.opacity(flashOpacity)

            ForEach(0..<shardCount, id: \.self) { i in
                let angle = Angle(degrees: Double(i) * (360.0 / Double(shardCount)))
                Rectangle()
                    .fill(Color.black)
                    .frame(width: shardSize, height: shardSize)
                    .rotationEffect(.degrees(45))
                    .offset(x: 6 + shardProgress * 90)
                    .rotationEffect(angle)
                    .opacity(1 - shardProgress)
                    .scaleEffect(1 - shardProgress * 0.65)
            }

            Text("BREAK")
                .font(.system(size: badgeSize, weight: .black, design: .condensed))
                .tracking(big ? 4 : 1.5)
                .foregroundColor(.white)
                .padding(.horizontal, big ? 26 : 11)
                .padding(.vertical, big ? 12 : 4)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: big ? 15 : 7))
                .scaleEffect(badgeScale)
                .opacity(badgeOpacity)
        }
        .offset(x: shakeOffset)
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in play() }
    }

    private func play() {
        flashOpacity = 0
        badgeScale = 1.8
        badgeOpacity = 0
        shardProgress = 0
        shakeOffset = 0

        withAnimation(.easeOut(duration: 0.08)) { flashOpacity = 0.85 }
        withAnimation(.easeOut(duration: 0.47).delay(0.08)) { flashOpacity = 0 }

        withAnimation(.easeOut(duration: big ? 0.75 : 0.6)) { shardProgress = 1 }

        withAnimation(.timingCurve(0.2, 0.85, 0.3, 1.25, duration: 0.3)) {
            badgeScale = 0.9
            badgeOpacity = 1
        }
        withAnimation(.timingCurve(0.2, 0.85, 0.3, 1.25, duration: 0.14).delay(0.3)) {
            badgeScale = 1.07
        }
        withAnimation(.timingCurve(0.2, 0.85, 0.3, 1.25, duration: 0.14).delay(0.44)) {
            badgeScale = 1.0
        }
        withAnimation(.easeIn(duration: 0.34).delay(0.76)) {
            badgeScale = 1.18
            badgeOpacity = 0
        }

        let shakeSteps: [(Double, CGFloat)] = [(0.0, 0), (0.1, -5), (0.2, 4), (0.3, -3), (0.4, 2), (0.5, 0)]
        for (delay, offset) in shakeSteps {
            withAnimation(.linear(duration: 0.1).delay(delay)) { shakeOffset = offset }
        }
    }
}

/// Translates the block down on press to compress its bottom "lip".
struct PressDownButtonStyle: ButtonStyle {
    var distance: CGFloat = 4
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? distance : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// A chunky button with a darker bottom lip that compresses on press.
struct ChunkyCapsuleButtonStyle: ButtonStyle {
    var fill: Color
    var lip: Color
    var radius: CGFloat = 11
    var lipHeight: CGFloat = 4

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

/// A small round +/− control button that scales down on press.
struct CircleControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Circle().fill(YASAColor.controlFill))
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
