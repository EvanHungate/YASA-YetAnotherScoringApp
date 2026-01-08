//
//  GameState.swift
//  YASA Watch App
//
//  Game state management for Ultimate Frisbee scorekeeper
//

import SwiftUI
import Combine

// Represents a snapshot of the game state for undo functionality
struct GameStateSnapshot {
    let scoreA: Int
    let scoreB: Int
    let breaksA: Int
    let breaksB: Int
    let pullingTeam: String
    let halftimeReached: Bool
    let rotationIndex: Int
    let totalPoints: Int
    let openCursor: Int
    let fmpCursor: Int
}

// Represents the needs for Open and FMP players for a given ratio
struct RatioNeeds {
    let o: Int  // Open players needed
    let f: Int  // FMP players needed
}

class GameState: ObservableObject {
    // Team configuration
    @Published var teamAName: String = "Team A"
    @Published var teamBName: String = "Team B"

    // Scores and breaks
    @Published var scoreA: Int = 0
    @Published var scoreB: Int = 0
    @Published var breaksA: Int = 0
    @Published var breaksB: Int = 0

    // Pulling
    @Published var pullingTeam: String = "a"  // "a" or "b"
    @Published var initialPuller: String = "a"

    // Rotation
    @Published var rotationCycle: [String] = []
    @Published var rotationIndex: Int = 0
    @Published var rotationStart: String = "O"  // "O" or "F"

    // Line rolling
    @Published var openCount: Int = 7
    @Published var fmpCount: Int = 7
    @Published var openCursor: Int = 0
    @Published var fmpCursor: Int = 0

    // Game state
    @Published var targetPoints: Int = 15
    @Published var totalPoints: Int = 0
    @Published var halftimeReached: Bool = false
    @Published var gameStarted: Bool = false
    @Published var showHalftimeModal: Bool = false
    @Published var showWinnerModal: Bool = false
    @Published var winningTeam: String = ""

    // History for undo
    private var history: [GameStateSnapshot] = []

    // MARK: - Setup Functions

    /// Builds the rotation cycle based on starting ratio
    func buildRotation(startRatio: String) -> [String] {
        let A = startRatio
        let B = startRatio == "O" ? "F" : "O"
        return ["\(A)2", "\(B)1", "\(B)2", "\(A)1"]
    }

    /// Returns the player needs for a given ratio label
    func ratioNeeds(label: String) -> RatioNeeds {
        let isO = label.starts(with: "O")
        return RatioNeeds(o: isO ? 4 : 3, f: isO ? 3 : 4)
    }

    /// Starts a new game with the configured settings
    func startGame() {
        // Build rotation cycle
        rotationCycle = buildRotation(startRatio: rotationStart)

        // Reset all state
        scoreA = 0
        scoreB = 0
        breaksA = 0
        breaksB = 0
        pullingTeam = initialPuller
        halftimeReached = false
        rotationIndex = 0
        totalPoints = 0
        openCursor = 0
        fmpCursor = 0
        history = []
        showHalftimeModal = false
        showWinnerModal = false
        winningTeam = ""

        gameStarted = true
    }

    // MARK: - Game Logic Functions

    /// Handles scoring for a team
    func score(team: String) {
        // 1. Save history for undo
        saveHistory()

        // 2. Update score
        if team == "a" {
            scoreA += 1
        } else {
            scoreB += 1
        }
        totalPoints += 1

        // 3. Check for break
        if team == pullingTeam {
            if team == "a" {
                breaksA += 1
            } else {
                breaksB += 1
            }
        }

        // 4. Advance rotation and lines
        advanceLines()
        rotationIndex = (rotationIndex + 1) % 4

        // 5. Update pulling team (scoring team pulls next)
        pullingTeam = team

        // 6. Check halftime
        if !halftimeReached && (scoreA == 8 || scoreB == 8) {
            halftimeReached = true
            showHalftimeModal = true
            return  // Don't check for win yet, let user acknowledge halftime first
        }

        // 7. Check for win
        let currentScore = team == "a" ? scoreA : scoreB
        if currentScore >= targetPoints {
            winningTeam = team
            showWinnerModal = true
        }
    }

    /// Continues from halftime
    func continueFromHalftime() {
        showHalftimeModal = false
        // Switch pulling team to opposite of initial puller
        pullingTeam = initialPuller == "a" ? "b" : "a"

        // Check for win after halftime
        if scoreA >= targetPoints {
            winningTeam = "a"
            showWinnerModal = true
        } else if scoreB >= targetPoints {
            winningTeam = "b"
            showWinnerModal = true
        }
    }

    /// Advances the line cursors based on players used
    func advanceLines() {
        guard rotationIndex < rotationCycle.count else { return }
        let label = rotationCycle[rotationIndex]
        let needs = ratioNeeds(label: label)

        openCursor = (openCursor + needs.o) % openCount
        fmpCursor = (fmpCursor + needs.f) % fmpCount
    }

    /// Returns the current line display string
    func currentLineDisplay() -> String {
        guard gameStarted && rotationIndex < rotationCycle.count else { return "" }

        let label = rotationCycle[rotationIndex]
        let needs = ratioNeeds(label: label)

        // Get Open players
        var openLine: [Int] = []
        for i in 0..<min(needs.o, openCount) {
            openLine.append(((openCursor + i) % openCount) + 1)
        }

        // Get FMP players
        var fmpLine: [Int] = []
        for i in 0..<min(needs.f, fmpCount) {
            fmpLine.append(((fmpCursor + i) % fmpCount) + 1)
        }

        return "O: \(openLine.map(String.init).joined(separator: ",")) | F: \(fmpLine.map(String.init).joined(separator: ","))"
    }

    /// Returns the current ratio label
    func currentRatioLabel() -> String {
        guard gameStarted && rotationIndex < rotationCycle.count else { return "" }
        return rotationCycle[rotationIndex]
    }

    /// Returns which team is receiving
    func receivingTeam() -> String {
        return pullingTeam == "a" ? "b" : "a"
    }

    // MARK: - History Functions

    /// Saves the current state to history
    private func saveHistory() {
        let snapshot = GameStateSnapshot(
            scoreA: scoreA,
            scoreB: scoreB,
            breaksA: breaksA,
            breaksB: breaksB,
            pullingTeam: pullingTeam,
            halftimeReached: halftimeReached,
            rotationIndex: rotationIndex,
            totalPoints: totalPoints,
            openCursor: openCursor,
            fmpCursor: fmpCursor
        )
        history.append(snapshot)
    }

    /// Undoes the last action
    func undo() {
        guard let last = history.popLast() else { return }

        scoreA = last.scoreA
        scoreB = last.scoreB
        breaksA = last.breaksA
        breaksB = last.breaksB
        pullingTeam = last.pullingTeam
        halftimeReached = last.halftimeReached
        rotationIndex = last.rotationIndex
        totalPoints = last.totalPoints
        openCursor = last.openCursor
        fmpCursor = last.fmpCursor

        // Clear any modals
        showHalftimeModal = false
        showWinnerModal = false
        winningTeam = ""
    }

    /// Returns true if undo is available
    func canUndo() -> Bool {
        return !history.isEmpty
    }

    // MARK: - Reset Function

    /// Resets the game back to setup
    func resetGame() {
        gameStarted = false
        scoreA = 0
        scoreB = 0
        breaksA = 0
        breaksB = 0
        pullingTeam = initialPuller
        halftimeReached = false
        rotationIndex = 0
        totalPoints = 0
        openCursor = 0
        fmpCursor = 0
        history = []
        showHalftimeModal = false
        showWinnerModal = false
        winningTeam = ""
    }
}
