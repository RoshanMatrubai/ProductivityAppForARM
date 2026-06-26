import SwiftUI

struct ContentView: View {
    // @AppStorage owns isDark. KVO on UserDefaults re-renders this view the instant
    // isDark changes — no shared object, no observation chain to break.
    @AppStorage("isDarkMode") private var isDark: Bool = true
    private var theme: ThemeManager { ThemeManager(isDark: isDark) }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .background(theme.foreground.opacity(0.15))
            PomodoroView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: isDark)
    }

    private var header: some View {
        HStack {
            Text("ZENITH")
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .tracking(6)
                .foregroundStyle(theme.foreground)
            Spacer()
            Button {
                isDark.toggle()
            } label: {
                Image(systemName: isDark ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(theme.foreground)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 580)
}
