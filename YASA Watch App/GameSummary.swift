//
//  GameSummary.swift
//  YASA Watch App
//
//  Immutable snapshot of a finished game, used for the finish screen and image export.
//

import Foundation

struct GameSummary {
    let teamAName: String
    let teamBName: String
    let scoreA: Int
    let scoreB: Int
    let breaksA: Int
    let breaksB: Int
    let totalPoints: Int
    let winnerName: String
    let date: Date
}
