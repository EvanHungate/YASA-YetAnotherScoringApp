//
//  GameState.swift
//  YASA
//
//  Game state management for Ultimate Frisbee scorekeeper (iOS)
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

// Codable struct for saving/loading game state
struct SavedGameState: Codable {
    let teamAName: String
    let teamBName: String
    let scoreA: Int
    let scoreB: Int
    let breaksA: Int
    let breaksB: Int
    let pullingTeam: String
    let initialPuller: String
    let rotationCycle: [String]
    let rotationIndex: Int
    let rotationStart: String
    let useLineRolling: Bool
    let openCount: Int
    let fmpCount: Int
    let openCursor: Int
    let fmpCursor: Int
    let targetPoints: Int
    let totalPoints: Int
    let halftimeReached: Bool
    let timestamp: Date
}

class GameState: ObservableObject {
    // Team configuration
    @Published var teamAName: String = "Team"
    @Published var teamBName: String = "Opposition"

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
    @Published var useLineRolling: Bool = false
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

    // Timing (for Finish screen duration)
    @Published var gameStartDate: Date = Date()
    @Published var finishedAt: Date?

    // Transient break-celebration triggers (incremented to retrigger the animation view)
    @Published var breakTriggerA: Int = 0
    @Published var breakTriggerB: Int = 0

    // History for undo
    private var history: [GameStateSnapshot] = []

    // MARK: - Initialization
    
    init() {
        loadTeamNames()
    }

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
        // Save team names for future games
        saveTeamNames()
        
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
        gameStartDate = Date()
        finishedAt = nil

        gameStarted = true

        // Save initial game state
        saveState()

        // Sync to Watch
        PhoneConnectivityManager.shared.sendGameState()
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
                breakTriggerA += 1
            } else {
                breaksB += 1
                breakTriggerB += 1
            }
        }

        // 4. Advance rotation and lines
        advanceLines()
        rotationIndex = (rotationIndex + 1) % 4

        // 5. Update pulling team (scoring team pulls next)
        pullingTeam = team

        // 6. Check halftime (first time either team reaches half of target)
        let halftimeThreshold = Int(ceil(Double(targetPoints) / 2.0))
        if !halftimeReached && (scoreA >= halftimeThreshold || scoreB >= halftimeThreshold) {
            halftimeReached = true
            showHalftimeModal = true
            PhoneConnectivityManager.shared.sendGameState()
            return  // Don't check for win yet, let user acknowledge halftime first
        }

        // 7. Check for win
        let currentScore = team == "a" ? scoreA : scoreB
        if currentScore >= targetPoints {
            winningTeam = team
            finishedAt = Date()
            showWinnerModal = true
            clearSavedState()
            PhoneConnectivityManager.shared.sendGameState()
        } else {
            saveState()
            PhoneConnectivityManager.shared.sendGameState()
        }
    }

    /// Manually finishes the game (e.g. "Finish Game" in Controls), regardless of score.
    func finishGame() {
        winningTeam = scoreA >= scoreB ? "a" : "b"
        finishedAt = Date()
        showWinnerModal = true
        clearSavedState()
        PhoneConnectivityManager.shared.sendGameState()
    }

    /// Game duration so far (live while playing, frozen once finished).
    var elapsedSeconds: Int {
        let end = finishedAt ?? Date()
        return max(0, Int(end.timeIntervalSince(gameStartDate)))
    }

    func formattedDuration() -> String {
        let total = elapsedSeconds
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    // MARK: - Controls overrides

    func adjustScore(team: String, delta: Int) {
        if team == "a" {
            scoreA = max(0, scoreA + delta)
        } else {
            scoreB = max(0, scoreB + delta)
        }
        saveState()
        PhoneConnectivityManager.shared.sendGameState()
    }

    func adjustBreaks(team: String, delta: Int) {
        if team == "a" {
            breaksA = max(0, breaksA + delta)
        } else {
            breaksB = max(0, breaksB + delta)
        }
        saveState()
        PhoneConnectivityManager.shared.sendGameState()
    }

    func setPullingOverride(team: String) {
        pullingTeam = team
        saveState()
        PhoneConnectivityManager.shared.sendGameState()
    }

    func setRatioIndex(_ index: Int) {
        guard index >= 0 && index < rotationCycle.count else { return }
        rotationIndex = index
        saveState()
        PhoneConnectivityManager.shared.sendGameState()
    }

    /// Continues from halftime
    func continueFromHalftime() {
        showHalftimeModal = false
        pullingTeam = initialPuller == "a" ? "b" : "a"

        if scoreA >= targetPoints {
            winningTeam = "a"
            showWinnerModal = true
            clearSavedState()
        } else if scoreB >= targetPoints {
            winningTeam = "b"
            showWinnerModal = true
            clearSavedState()
        } else {
            saveState()
        }
        PhoneConnectivityManager.shared.sendGameState()
    }

    /// Advances the line cursors based on players used
    func advanceLines() {
        guard useLineRolling && rotationIndex < rotationCycle.count else { return }
        let label = rotationCycle[rotationIndex]
        let needs = ratioNeeds(label: label)

        openCursor = (openCursor + needs.o) % openCount
        fmpCursor = (fmpCursor + needs.f) % fmpCount
    }

    /// Returns the current line display string
    func currentLineDisplay() -> String {
        guard useLineRolling && gameStarted && rotationIndex < rotationCycle.count else { return "" }

        let label = rotationCycle[rotationIndex]
        let needs = ratioNeeds(label: label)

        var openLine: [Int] = []
        for i in 0..<min(needs.o, openCount) {
            openLine.append(((openCursor + i) % openCount) + 1)
        }

        var fmpLine: [Int] = []
        for i in 0..<min(needs.f, fmpCount) {
            fmpLine.append(((fmpCursor + i) % fmpCount) + 1)
        }

        return "O: \(openLine.map(String.init).joined(separator: ",")) | F: \(fmpLine.map(String.init).joined(separator: ","))"
    }

    /// Suggested Open-line player numbers for the current point.
    func currentOpenNumbers() -> [Int] {
        guard useLineRolling && gameStarted && rotationIndex < rotationCycle.count else { return [] }
        let needs = ratioNeeds(label: rotationCycle[rotationIndex])
        return (0..<min(needs.o, openCount)).map { ((openCursor + $0) % openCount) + 1 }
    }

    /// Suggested FMP-line player numbers for the current point.
    func currentFmpNumbers() -> [Int] {
        guard useLineRolling && gameStarted && rotationIndex < rotationCycle.count else { return [] }
        let needs = ratioNeeds(label: rotationCycle[rotationIndex])
        return (0..<min(needs.f, fmpCount)).map { ((fmpCursor + $0) % fmpCount) + 1 }
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

        showHalftimeModal = false
        showWinnerModal = false
        winningTeam = ""

        PhoneConnectivityManager.shared.sendGameState()
    }

    func canUndo() -> Bool {
        return !history.isEmpty
    }

    // MARK: - Reset Function

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
        finishedAt = nil

        clearSavedState()
    }

    /// Builds an immutable snapshot of the finished game for display/export.
    func makeSummary() -> GameSummary {
        let winner: String
        if winningTeam == "a" {
            winner = teamAName
        } else if winningTeam == "b" {
            winner = teamBName
        } else {
            winner = scoreA >= scoreB ? teamAName : teamBName  // fallback if winningTeam unset
        }
        return GameSummary(
            teamAName: teamAName, teamBName: teamBName,
            scoreA: scoreA, scoreB: scoreB,
            breaksA: breaksA, breaksB: breaksB,
            totalPoints: totalPoints,
            winnerName: winner,
            date: Date()
        )
    }

    // MARK: - Persistence Functions

    private static let savedGameKey = "savedGameState"
    private static let teamNamesKey = "teamNames"
    
    /// Save team names separately for reuse across games
    func saveTeamNames() {
        let names = ["teamA": teamAName, "teamB": teamBName]
        UserDefaults.standard.set(names, forKey: Self.teamNamesKey)
    }
    
    /// Load previously used team names
    func loadTeamNames() {
        if let names = UserDefaults.standard.dictionary(forKey: Self.teamNamesKey) as? [String: String] {
            if let teamA = names["teamA"], !teamA.isEmpty {
                teamAName = teamA
            }
            if let teamB = names["teamB"], !teamB.isEmpty {
                teamBName = teamB
            }
        }
    }

    func saveState() {
        guard gameStarted else { return }

        let savedState = SavedGameState(
            teamAName: teamAName,
            teamBName: teamBName,
            scoreA: scoreA,
            scoreB: scoreB,
            breaksA: breaksA,
            breaksB: breaksB,
            pullingTeam: pullingTeam,
            initialPuller: initialPuller,
            rotationCycle: rotationCycle,
            rotationIndex: rotationIndex,
            rotationStart: rotationStart,
            useLineRolling: useLineRolling,
            openCount: openCount,
            fmpCount: fmpCount,
            openCursor: openCursor,
            fmpCursor: fmpCursor,
            targetPoints: targetPoints,
            totalPoints: totalPoints,
            halftimeReached: halftimeReached,
            timestamp: Date()
        )

        if let encoded = try? JSONEncoder().encode(savedState) {
            UserDefaults.standard.set(encoded, forKey: Self.savedGameKey)
        }
    }

    func loadSavedState() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: Self.savedGameKey),
              let savedState = try? JSONDecoder().decode(SavedGameState.self, from: data) else {
            return false
        }

        let hoursSinceLastSave = Date().timeIntervalSince(savedState.timestamp) / 3600
        if hoursSinceLastSave > 24 {
            clearSavedState()
            return false
        }

        teamAName = savedState.teamAName
        teamBName = savedState.teamBName
        scoreA = savedState.scoreA
        scoreB = savedState.scoreB
        breaksA = savedState.breaksA
        breaksB = savedState.breaksB
        pullingTeam = savedState.pullingTeam
        initialPuller = savedState.initialPuller
        rotationCycle = savedState.rotationCycle
        rotationIndex = savedState.rotationIndex
        rotationStart = savedState.rotationStart
        useLineRolling = savedState.useLineRolling
        openCount = savedState.openCount
        fmpCount = savedState.fmpCount
        openCursor = savedState.openCursor
        fmpCursor = savedState.fmpCursor
        targetPoints = savedState.targetPoints
        totalPoints = savedState.totalPoints
        halftimeReached = savedState.halftimeReached
        gameStarted = true

        return true
    }

    static func hasSavedGame() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: savedGameKey),
              let savedState = try? JSONDecoder().decode(SavedGameState.self, from: data) else {
            return false
        }

        let hoursSinceLastSave = Date().timeIntervalSince(savedState.timestamp) / 3600
        return hoursSinceLastSave <= 24
    }

    func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: Self.savedGameKey)
    }
}
