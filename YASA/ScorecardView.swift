//
//  ScorecardView.swift
//  YASA
//
//  Pure, non-interactive scorecard. Shown inside FinishView and rendered to an image
//  by ScorecardRenderer. Width is imposed by the caller; height is intrinsic.
//

import SwiftUI

struct ScorecardView: View {
    let summary: GameSummary

    var body: some View {
        VStack(spacing: 10) {
            Text("FINAL").font(.caption2).foregroundStyle(.secondary).tracking(2)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                teamColumn(summary.teamAName, summary.scoreA, summary.breaksA)
                Text("–").font(.title2).foregroundStyle(.secondary)
                teamColumn(summary.teamBName, summary.scoreB, summary.breaksB)
            }
            Divider()
            Label("\(summary.winnerName) wins", systemImage: "trophy.fill")
                .font(.headline).foregroundStyle(.yellow)
            HStack(spacing: 12) {
                Text("\(summary.totalPoints) pts played").font(.caption2).foregroundStyle(.secondary)
                Text(summary.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .foregroundStyle(.white)
    }

    private func teamColumn(_ name: String, _ score: Int, _ breaks: Int) -> some View {
        VStack(spacing: 2) {
            Text(name).font(.caption).lineLimit(1).minimumScaleFactor(0.6)
            Text("\(score)").font(.system(size: 36, weight: .bold, design: .rounded))
            Text("\(breaks) brk").font(.caption2).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ScorecardView(summary: GameSummary(
        teamAName: "Hawks", teamBName: "Eagles",
        scoreA: 15, scoreB: 12, breaksA: 3, breaksB: 1,
        totalPoints: 27, winnerName: "Hawks", date: .now))
}
