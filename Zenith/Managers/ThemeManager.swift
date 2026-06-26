import SwiftUI

@Observable
final class ThemeManager {
    @ObservationIgnored
    @AppStorage("isDarkMode") var isDark: Bool = true

    var background: Color { isDark ? .black : .white }
    var foreground: Color { isDark ? .white : .black }
    var secondaryForeground: Color { isDark ? Color(white: 0.6) : Color(white: 0.4) }
}
