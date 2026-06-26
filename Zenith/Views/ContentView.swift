import SwiftUI

struct ContentView: View {
    @State private var theme = ThemeManager()

    var body: some View {
        VStack(spacing: 24) {
            Text("Zenith")
                .font(.system(size: 48, weight: .black, design: .default))
                .foregroundStyle(theme.foreground)
            Text("Minimalist productivity for macOS")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(theme.secondaryForeground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .background(theme.background.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            Button {
                theme.isDark.toggle()
            } label: {
                Image(systemName: theme.isDark ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(theme.foreground)
                    .padding(16)
            }
            .buttonStyle(.plain)
        }
        .animation(.easeInOut(duration: 0.2), value: theme.isDark)
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 580)
}
