import Foundation
import SwiftUI

extension Color {
    static let brandBlue = Color(hex: "#0052D9")
    static let primaryFontColor = Color(hex: "#222427")
    static let secondaryFontColor = Color(hex: "#51565D")
    static let textErrorFontColor = Color(hex: "#CC251C")
    static let seperateLineColor = Color(hex: "#C2C2C2")
    static let activeGreen = Color(hex: "#00A870")
    static let disableBackground = Color(hex: "#EAEAEA")
    static let warningBackground = Color(hex: "#ED7B2F")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
