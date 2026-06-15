//
//  WatchConnectivityManager.swift
//  YASA Watch App
//
//  Manages WatchConnectivity session for syncing with iPhone
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    @Published var isReachable = false
    @Published var isActivated = false

    weak var gameState: GameState?
    private var lastSyncedTimestamp: Date?

    private override init() {
        super.init()
    }

    /// Activate connectivity session with reference to game state
    func activate(with gameState: GameState) {
        self.gameState = gameState

        guard WCSession.isSupported() else {
            print("[WatchConnectivity] Not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Send current game state to iPhone
    func sendGameState() {
        guard let gameState = gameState else {
            print("[WatchConnectivity] No game state to send")
            return
        }

        guard WCSession.default.activationState == .activated else {
            print("[WatchConnectivity] Session not activated")
            return
        }

        // Don't send if game hasn't started
        guard gameState.gameStarted else {
            return
        }

        // Convert game state to dictionary
        let message: [String: Any] = [
            "type": "GAME_STATE_UPDATE",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "payload": gameStateToDictionary()
        ]

        // Send immediately if iPhone is reachable
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("[WatchConnectivity] Failed to send message: \(error.localizedDescription)")
            }
            print("[WatchConnectivity] Sent immediate update to iPhone")
        } else {
            // Queue for later delivery
            WCSession.default.transferUserInfo(message)
            print("[WatchConnectivity] Queued update for iPhone")
        }

        lastSyncedTimestamp = Date()
    }

    /// Queues the rendered scorecard PNG for background transfer to the iPhone,
    /// which saves it to Photos. Works whether or not the iPhone is currently reachable.
    func sendScorecard(fileURL: URL) {
        guard WCSession.isSupported() else { return }
        guard WCSession.default.activationState == .activated else {
            print("[WatchConnectivity] Session not activated; cannot send scorecard")
            return
        }
        WCSession.default.transferFile(fileURL, metadata: ["type": "scorecard"])
        print("[WatchConnectivity] Queued scorecard file for iPhone")
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("[WatchConnectivity] Activation failed: \(error.localizedDescription)")
                return
            }

            self.isActivated = activationState == .activated
            self.isReachable = session.isReachable

            print("[WatchConnectivity] Session activated, reachable: \(session.isReachable)")

            // Request state from iPhone after activation
            if activationState == .activated {
                self.requestState()
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("[WatchConnectivity] Reachability changed: \(session.isReachable)")

            // Send current state when iPhone becomes reachable
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
            print("[WatchConnectivity] Invalid message format")
            return
        }

        print("[WatchConnectivity] Received message type: \(type)")

        switch type {
        case "GAME_STATE_UPDATE":
            if let payload = message["payload"] as? [String: Any] {
                updateGameState(from: payload, remoteTimestamp: message["timestamp"] as? String)
            }

        case "STATE_REQUEST":
            // iPhone is requesting our current state
            sendGameState()

        default:
            print("[WatchConnectivity] Unknown message type: \(type)")
        }
    }

    private func updateGameState(from payload: [String: Any], remoteTimestamp: String?) {
        guard let gameState = gameState else { return }

        // Parse timestamp for conflict resolution
        let remoteDate = remoteTimestamp.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
        let localDate = lastSyncedTimestamp ?? Date.distantPast

        // If remote is clearly newer (> 1 second), accept it
        let timeDiff = remoteDate.timeIntervalSince(localDate)

        if timeDiff < -1.0 {
            // Local is newer, don't update
            print("[WatchConnectivity] Local state is newer, ignoring remote")
            return
        }

        // Update game state
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
        if let gameStarted = payload["gameStarted"] as? Bool {
            gameState.gameStarted = gameStarted
        }

        lastSyncedTimestamp = remoteDate
        print("[WatchConnectivity] Updated game state from iPhone")
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

    private func requestState() {
        guard WCSession.default.activationState == .activated else { return }

        let request: [String: Any] = [
            "type": "STATE_REQUEST",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(request, replyHandler: nil)
            print("[WatchConnectivity] Requested state from iPhone")
        }
    }
}
