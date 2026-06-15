//
//  YASA_Watch_AppTests.swift
//  YASA Watch AppTests
//
//  Created by Evan Hungate on 2026-01-07.
//

import XCTest
@testable import YASA_Watch_App

// MARK: - How to verify this feature (the project builds only on macOS / Xcode, not Windows)
//
// Unit tests (this file):
//   xcodebuild test -scheme "YASA Watch App" \
//     -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'
//
// Scorecard "Save to Phone" end-to-end (paired watch + iPhone sims; launch the iOS
// app once so it can receive the WCSession file transfer):
//   1. Play to the target score -> a finish sheet (not an alert) shows the scorecard.
//   2. Watch "Save to Phone" renders a PNG and queues WCSession.transferFile.
//   3. iPhone: the first transfer triggers the Photos add-only permission prompt -> Allow;
//      the image lands in Photos and the iOS status banner shows "saved".
//   4. iOS standalone: finishing a game on the phone shows the same finish sheet, whose
//      "Save to Photos" saves the rendered card directly to Photos.
//
// Gotchas:
//   - The Photos prompt needs INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription on the iOS
//     "YASA" target (Debug + Release, in project.pbxproj); without it auth returns .denied.
//   - New .swift files auto-compile via each target's fileSystemSynchronizedGroups; if one
//     doesn't build, check its target membership.
//   - Watch ScorecardRenderer uses ImageRenderer.uiImage; see its note for the
//     CGImage + ImageIO fallback if a toolchain lacks UIKit/uiImage.

final class YASA_Watch_AppTests: XCTestCase {

    func testSummaryResolvesWinnerNameFromWinningTeam() {
        let gs = GameState()
        gs.teamAName = "Hawks"; gs.teamBName = "Eagles"
        gs.scoreA = 10; gs.scoreB = 15
        gs.winningTeam = "b"
        let s = gs.makeSummary()
        XCTAssertEqual(s.winnerName, "Eagles")
        XCTAssertEqual(s.scoreA, 10)
        XCTAssertEqual(s.scoreB, 15)
    }

    func testSummaryFallsBackToHigherScoreWhenWinnerUnset() {
        let gs = GameState()
        gs.teamAName = "Hawks"; gs.teamBName = "Eagles"
        gs.scoreA = 15; gs.scoreB = 12
        gs.winningTeam = ""
        XCTAssertEqual(gs.makeSummary().winnerName, "Hawks")
    }

    func testSummaryCarriesBreaksAndTotalPoints() {
        let gs = GameState()
        gs.breaksA = 3; gs.breaksB = 1; gs.totalPoints = 27
        let s = gs.makeSummary()
        XCTAssertEqual(s.breaksA, 3)
        XCTAssertEqual(s.breaksB, 1)
        XCTAssertEqual(s.totalPoints, 27)
    }
}
