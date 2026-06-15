//
//  ScorecardRenderer.swift
//  YASA Watch App
//
//  Renders a ScorecardView to a PNG file for transfer to the iPhone.
//

import SwiftUI
import WatchKit
import UIKit

@MainActor
enum ScorecardRenderer {
    /// Renders the scorecard to a PNG in the temporary directory; returns the file URL or nil on failure.
    static func renderPNG(_ summary: GameSummary) -> URL? {
        let card = ScorecardView(summary: summary).frame(width: 360)
        let renderer = ImageRenderer(content: card)
        renderer.scale = WKInterfaceDevice.current().screenScale
        // Contingency: if a future watchOS toolchain drops UIKit / ImageRenderer.uiImage,
        // render via `renderer.cgImage` and write it to `url` with CGImageDestination
        // (ImageIO + UTType.png) instead of the uiImage/pngData path below.
        guard let image = renderer.uiImage, let data = image.pngData() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("yasa-scorecard.png")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
