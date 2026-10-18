//
//  DesignScreenshotTests.swift
//  Numer0nLensTests
//

@testable import Numer0nLens
import SwiftUI
import XCTest

/// 新デザインの見本をライト / ダークで画像にし、テスト結果（xcresult）に添付する。
/// CI の artifact（TestResults.xcresult）から取り出して、PR で見た目を確かめるために使う。
@MainActor
final class DesignScreenshotTests: XCTestCase {
    func testDesignGallery() throws {
        try attach(DesignGalleryContent(), name: "design-gallery")
    }

    private func attach(_ view: some View, name: String) throws {
        for scheme in [ColorScheme.light, .dark] {
            let renderer = ImageRenderer(
                content: view
                    .frame(width: 393)
                    .environment(\.colorScheme, scheme)
            )
            renderer.scale = 2
            let image = try XCTUnwrap(renderer.uiImage, "\(name) (\(scheme))")
            let attachment = XCTAttachment(image: image)
            attachment.name = "\(name)-\(scheme == .dark ? "dark" : "light")"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
}
