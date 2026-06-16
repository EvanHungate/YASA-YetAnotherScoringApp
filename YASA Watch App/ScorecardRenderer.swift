//
//  ScorecardRenderer.swift
//  YASA Watch App
//
//  Renders a ScorecardView to a PNG file for transfer to the iPhone.
//

import SwiftUI
import WatchKit
import ImageIO
import UniformTypeIdentifiers

@MainActor
enum ScorecardRenderer {
    /// Renders the scorecard to a PNG in the temporary directory; returns the file URL or nil on failure.
    static func renderPNG(_ summary: GameSummary) -> URL? {
        let card = ScorecardView(summary: summary).frame(width: 360)
        let renderer = ImageRenderer(content: card)
        renderer.scale = WKInterfaceDevice.current().screenScale
        guard let cgImage = renderer.cgImage else { return nil }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("yasa-scorecard.png")
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil
        ) else { return nil }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return url
    }
}
