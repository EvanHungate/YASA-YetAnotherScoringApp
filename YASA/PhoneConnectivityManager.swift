//
//  PhoneConnectivityManager.swift
//  YASA
//
//  Manages WatchConnectivity session for syncing with Apple Watch (iOS side)
//

import Foundation
import WatchConnectivity
import Combine

class PhoneConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneConnectivityManager()

    @Published var isReachable = false
    @Published var isActivated = false
    @Published var isPaired = false
    @Published var isWatchAppInstalled = false

    weak var gameState: GameState?
    private var lastSyncedTimestamp: Date?

    private override init() {
        super.init()
    }

    /// Activate connectivity session with reference to game state
    func activate(with gameState: GameState) {
        self.gameState = gameState

        guard WCSession.isSupported() else {
            print("[PhoneConnectivity] WatchConnectivity not supported")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Send current game state to Watch
    func sendGameState() {
        guard let gameState = gameState else {
            print("[PhoneConnectivity] No game state to send")
            return
        }

        guard WCSession.default.activationState == .activated else {
            print("[PhoneConnectivity] Session not activated")
            return
        }

        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            print("[PhoneConnectivity] Watch not paired or app not installed")
            return
        }

        let message: [String: Any] = [
            "type": "GAME_STATE_UPDATE",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "payload": gameStateToDictionary()
        ]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("[PhoneConnectivity] Failed to send message: \(error.localizedDescription)")
            }
            print("[PhoneConnectivity] Sent immediate update to Watch")
        } else {
            WCSession.default.transferUserInfo(message)
            print("[PhoneConnectivity] Queued update for Watch")
        }

        lastSyncedTimestamp = Date()
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("[PhoneConnectivity] Activation failed: \(error.localizedDescription)")
                return
            }

            self.isActivated = activationState == .activated
            self.isReachable = session.isReachable
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled

            print("[PhoneConnectivity] Session activated - paired: \(session.isPaired), watch app installed: \(session.isWatchAppInstalled), reachable: \(session.isReachable)")

            // Send current state when session activates
            if activationState == .activated && session.isReachable {
                self.sendGameState()
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("[PhoneConnectivity] Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("[PhoneConnectivity] Session deactivated - reactivating")
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("[PhoneConnectivity] Reachability changed: \(session.isReachable)")

            // Send current state when Watch becomes reachable
            if session.isReachable {
                self.sendGameState()
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleIncomingMessage(message)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            self.handleIncomingMessage(userInfo)
        }
    }

    // MARK: - Private Methods

    private func handleIncomingMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else {
            print("[PhoneConnectivity] Invalid message format")
            return
        }

        print("[PhoneConnectivity] Received message type: \(type)")

        switch type {
        case "GAME_STATE_UPDATE":
            if let payload = message["payload"] as? [String: Any] {
                updateGameState(from: payload, remoteTimestamp: message["timestamp"] as? String)
            }

        case "STATE_REQUEST":
            sendGameState()

        default:
            print("[PhoneConnectivity] Unknown message type: \(type)")
        }
    }

    private func updateGameState(from payload: [String: Any], remoteTimestamp: String?) {
        guard let gameState = gameState else { return }

        let remoteDate = remoteTimestamp.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
        let localDate = lastSyncedTimestamp ?? Date.distantPast

        let timeDiff = remoteDate.timeIntervalSince(localDate)

        // If local is clearly newer, don't update (we're the source of truth for setup)
        if timeDiff < -1.0 && gameState.gameStarted {
            print("[PhoneConnectivity] Local state is newer, ignoring remote")
            return
        }

        // Update game state from Watch
        if let teamAName = payload["teamAName"] as? String {
            gameState.teamAName = teamAName
        }
        if let teamBName = payload["teamBName"] as? String {
            gameState.teamBName = teamBName
        }
        if let scoreA = payload["scoreA"] as? Int {
            gameState.scoreA = scoreA
        }
        if let scoreB = payload["scoreB"] as? Int {
            gameState.scoreB = scoreB
        }
        if let breaksA = payload["breaksA"] as? Int {
            gameState.breaksA = breaksA
        }
        if let breaksB = payload["breaksB"] as? Int {
            gameState.breaksB = breaksB
        }
        if let pullingTeam = payload["pullingTeam"] as? String {
            gameState.pullingTeam = pullingTeam
        }
        if let initialPuller = payload["initialPuller"] as? String {
            gameState.initialPuller = initialPuller
        }
        if let rotationCycle = payload["rotationCycle"] as? [String] {
            gameState.rotationCycle = rotationCycle
        }
        if let rotationIndex = payload["rotationIndex"] as? Int {
            gameState.rotationIndex = rotationIndex
        }
        if let rotationStart = payload["rotationStart"] as? String {
            gameState.rotationStart = rotationStart
        }
        if let useLineRolling = payload["useLineRolling"] as? Bool {
            gameState.useLineRolling = useLineRolling
        }
        if let openCount = payload["openCount"] as? Int {
            gameState.openCount = openCount
        }
        if let fmpCount = payload["fmpCount"] as? Int {
            gameState.fmpCount = fmpCount
        }
        if let openCursor = payload["openCursor"] as? Int {
            gameState.openCursor = openCursor
        }
        if let fmpCursor = payload["fmpCursor"] as? Int {
            gameState.fmpCursor = fmpCursor
        }
        if let targetPoints = payload["targetPoints"] as? Int {
            gameState.targetPoints = targetPoints
        }
        if let totalPoints = payload["totalPoints"] as? Int {
            gameState.totalPoints = totalPoints
        }
        if let halftimeReached = payload["halftimeReached"] as? Bool {
            gameState.halftimeReached = halftimeReached
        }
        if let gameStartedValue = payload["gameStarted"] as? Bool {
            gameState.gameStarted = gameStartedValue
        }

        lastSyncedTimestamp = remoteDate
        print("[PhoneConnectivity] Updated game state from Watch - Score: \(gameState.scoreA)-\(gameState.scoreB)")
    }

    private func gameStateToDictionary() -> [String: Any] {
        guard let gameState = gameState else { return [:] }

        return [
            "teamAName": gameState.teamAName,
            "teamBName": gameState.teamBName,
            "scoreA": gameState.scoreA,
            "scoreB": gameState.scoreB,
            "breaksA": gameState.breaksA,
            "breaksB": gameState.breaksB,
            "pullingTeam": gameState.pullingTeam,
            "initialPuller": gameState.initialPuller,
            "rotationCycle": gameState.rotationCycle,
            "rotationIndex": gameState.rotationIndex,
            "rotationStart": gameState.rotationStart,
            "useLineRolling": gameState.useLineRolling,
            "openCount": gameState.openCount,
            "fmpCount": gameState.fmpCount,
            "openCursor": gameState.openCursor,
            "fmpCursor": gameState.fmpCursor,
            "targetPoints": gameState.targetPoints,
            "totalPoints": gameState.totalPoints,
            "halftimeReached": gameState.halftimeReached,
            "gameStarted": gameState.gameStarted,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
    }
}
