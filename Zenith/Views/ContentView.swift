import SwiftUI

struct ContentView: View {
    @State private var theme = ThemeManager()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .background(theme.foreground.opacity(0.15))
            PomodoroView(theme: theme)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: theme.isDark)
    }

    private var header: some View {
        HStack {
            Text("ZENITH")
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .tracking(6)
                .foregroundStyle(theme.foreground)
            Spacer()
            Button {
                theme.isDark.toggle()
            } label: {
                Image(systemName: theme.isDark ? "sun.max.fill" : "moon.fill")
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
