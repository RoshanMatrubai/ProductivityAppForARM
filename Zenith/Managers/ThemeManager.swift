import SwiftUI

// Pure value-type color resolver. No observation needed — views own isDark via @AppStorage.
struct ThemeManager {
    var isDark: Bool

    var background: Color           { isDark ? .black : .white }
    var foreground: Color           { isDark ? .white : .black }
    var secondaryForeground: Color  { isDark ? Color(white: 0.6) : Color(white: 0.4) }
}
