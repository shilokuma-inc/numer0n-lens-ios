// アプリアイコン（1024×1024 の PNG）を描く。アプリのターゲットには入れない。
//
// 使い方（リポジトリ直下で）:
//   swift scripts/generate-app-icon.swift Numer0nLens/Assets.xcassets/AppIcon.appiconset/AppIcon.png
//
// 古代エジプトの王の名を囲む枠（カルトゥーシュ）に数字を縦に刻み、真ん中の数字をレンズで覗く図柄。
// 色はアプリの配色トークン（Assets.xcassets の Color Set）と、元のアイコンの紺・ミントに合わせる。
// 数字は同梱の El Messiri（Numer0nLens/Fonts）を太さ 700 で使う。

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size: CGFloat = 1_024

/// 0xRRGGBB を色にする。
func color(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

enum IconColor {
    /// 背景の紺（元のアイコンの左上と右下）。
    static let navyTop = color(0x0E1B33)
    static let navyBottom = color(0x1A4A72)
    /// カルトゥーシュの面（Paper のライト）。
    static let paper = color(0xF3ECDC)
    /// 縁取りの金（Bite のダーク）。
    static let gold = color(0xF4C25B)
    /// 数字（Ink のライト）。
    static let ink = color(0x142849)
    /// レンズ（Brand のダーク＝元のアイコンのミント）。
    static let mint = color(0x81F2E0)
}

/// 同梱の El Messiri を、指定した太さで読み込む。
func elMessiri(size fontSize: CGFloat, weight: CGFloat) -> CTFont {
    let url = URL(fileURLWithPath: "Numer0nLens/Fonts/ElMessiri-VariableFont_wght.ttf")
    guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
          let base = descriptors.first else {
        fatalError("フォントを読み込めません: \(url.path)（リポジトリ直下で実行してください）")
    }
    // 可変フォントの軸 'wght'。
    let weightAxis = 0x7767_6874
    let variation = [kCTFontVariationAttribute: [weightAxis: weight]] as CFDictionary
    let descriptor = CTFontDescriptorCreateCopyWithAttributes(base, variation)
    return CTFontCreateWithFontDescriptor(descriptor, fontSize, nil)
}

/// 文字を、中心が `center` に来るように描く。
func drawText(_ text: String, font: CTFont, color fill: CGColor, center: CGPoint, in context: CGContext) {
    let attributes = [kCTFontAttributeName: font, kCTForegroundColorAttributeName: fill] as CFDictionary
    guard let string = CFAttributedStringCreate(nil, text as CFString, attributes) else {
        return
    }
    let line = CTLineCreateWithAttributedString(string)
    let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
    context.textPosition = CGPoint(x: center.x - bounds.midX, y: center.y - bounds.midY)
    CTLineDraw(line, context)
}

func drawBackground(in context: CGContext) {
    let colors = [IconColor.navyTop, IconColor.navyBottom] as CFArray
    guard let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: colors, locations: [0, 1]) else {
        return
    }
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

    // 奥にうっすらとピラミッドを置く。
    context.setFillColor(color(0xFFFFFF, alpha: 0.06))
    context.beginPath()
    context.move(to: CGPoint(x: -40, y: 0))
    context.addLine(to: CGPoint(x: size / 2, y: 640))
    context.addLine(to: CGPoint(x: size + 40, y: 0))
    context.closePath()
    context.fillPath()
}

/// 縦長のカルトゥーシュ（王の名を囲む枠）と、下の結び目の横棒。
func drawCartouche(in context: CGContext) {
    let body = CGRect(x: size / 2 - 180, y: 190, width: 360, height: 700)
    let path = CGPath(roundedRect: body, cornerWidth: 180, cornerHeight: 180, transform: nil)
    context.setFillColor(IconColor.paper)
    context.addPath(path)
    context.fillPath()
    context.setStrokeColor(IconColor.gold)
    context.setLineWidth(28)
    context.addPath(path)
    context.strokePath()

    let tie = CGRect(x: size / 2 - 220, y: 150, width: 440, height: 44)
    context.setFillColor(IconColor.gold)
    context.addPath(CGPath(roundedRect: tie, cornerWidth: 20, cornerHeight: 20, transform: nil))
    context.fillPath()
}

/// 縦に刻んだ数字。
func drawDigits(in context: CGContext) {
    let font = elMessiri(size: 175, weight: 700)
    for (digit, centerY) in zip(["0", "1", "2"], [795.0, 540.0, 285.0]) {
        drawText(digit, font: font, color: IconColor.ink, center: CGPoint(x: size / 2, y: centerY), in: context)
    }
}

/// 真ん中の数字を覗くレンズ。紙の上でも見えるよう、紺で縁取ってからミントを重ねる。
func drawLens(in context: CGContext) {
    let center = CGPoint(x: size / 2, y: 540)
    let radius: CGFloat = 138
    let angle = -CGFloat.pi / 4
    let handleStart = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
    let handleEnd = CGPoint(x: center.x + cos(angle) * (radius + 230), y: center.y + sin(angle) * (radius + 230))

    context.setLineCap(.round)
    for (stroke, ring, handle) in [(IconColor.ink, 54.0, 74.0), (IconColor.mint, 30.0, 50.0)] {
        context.setStrokeColor(stroke)
        context.setLineWidth(ring)
        context.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        context.strokePath()
        context.setLineWidth(handle)
        context.move(to: handleStart)
        context.addLine(to: handleEnd)
        context.strokePath()
    }
}

guard CommandLine.arguments.count == 2 else {
    fatalError("使い方: swift scripts/generate-app-icon.swift <書き出す PNG のパス>")
}
let output = URL(fileURLWithPath: CommandLine.arguments[1])

// App Store のアイコンは透過を持てないので、アルファの無い RGB で描く。
guard let context = CGContext(
    data: nil,
    width: Int(size),
    height: Int(size),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
    fatalError("描画の準備ができません")
}
drawBackground(in: context)
drawCartouche(in: context)
drawDigits(in: context)
drawLens(in: context)

guard let image = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("画像を書き出せません: \(output.path)")
}
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("画像を書き出せません: \(output.path)")
}
print("書き出しました: \(output.path)")
