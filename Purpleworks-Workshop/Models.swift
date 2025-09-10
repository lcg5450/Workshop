//
//  Models.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI
import SwiftData

@Model
final class Team {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var score: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        score: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.score = score
        self.createdAt = createdAt
    }

    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
}

// MARK: - Color <-> Hex 유틸
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b, a: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1
        case 8:
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8) / 255
            a = Double(rgb & 0x000000FF) / 255
        default:
            return nil
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func toHex(includeAlpha: Bool = false) -> String? {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        if includeAlpha {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255)),
                lroundf(Float(a * 255))
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255))
            )
        }
        #else
        return nil
        #endif
    }

    static var teamPalette: [Color] {
        [
            .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue,
            .indigo, .purple, .pink, .brown, .gray
        ]
    }

    static var randomTeam: Color {
        teamPalette.randomElement() ?? .blue
    }
}
