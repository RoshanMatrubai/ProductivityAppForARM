import SwiftUI

enum ZenithTheme: String, CaseIterable, Codable {
    case obsidian
    case paper
    case creme
    case slate
    case sepia

    var background: Color {
        switch self {
        case .obsidian: Color(hex: "#000000")
        case .paper:    Color(hex: "#FFFFFF")
        case .creme:    Color(hex: "#F5F0E8")
        case .slate:    Color(hex: "#1E2328")
        case .sepia:    Color(hex: "#2B1D0E")
        }
    }

    var foreground: Color {
        switch self {
        case .obsidian: Color(hex: "#FFFFFF")
        case .paper:    Color(hex: "#000000")
        case .creme:    Color(hex: "#2C2417")
        case .slate:    Color(hex: "#C8CDD4")
        case .sepia:    Color(hex: "#D4A96A")
        }
    }

    var secondary: Color { foreground.opacity(0.45) }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct ThemeManager {
    var theme: ZenithTheme

    var background: Color        { theme.background }
    var foreground: Color        { theme.foreground }
    var secondaryForeground: Color { theme.secondary }
}
