//
//  ScorecardRenderer.swift
//  YASA
//
//  Renders a ScorecardView to a PNG file for saving to Photos.
//

import SwiftUI
import UIKit

@MainActor
enum ScorecardRenderer {
    /// Renders the scorecard to a PNG in the temporary directory; returns the file URL or nil on failure.
    /// `scale` should come from the SwiftUI `\.displayScale` environment.
    static func renderPNG(_ summary: GameSummary, scale: CGFloat) -> URL? {
        let card = ScorecardView(summary: summary).frame(width: 360)
        let renderer = ImageRenderer(content: card)
        renderer.scale = scale
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
