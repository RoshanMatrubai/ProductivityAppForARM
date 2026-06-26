import SwiftUI

struct PomodoroView: View {
    @Bindable var theme: ThemeManager
    @State private var timer = TimerViewModel()

    var body: some View {
        VStack(spacing: 32) {
            phaseLabel
            countdown
            progressBar
            controls
        }
        .padding(32)
    }

    // MARK: - Subviews

    private var phaseLabel: some View {
        Text(timer.currentPhase.label.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .tracking(4)
            .foregroundStyle(theme.secondaryForeground)
            .animation(.easeInOut(duration: 0.3), value: timer.currentPhase)
    }

    private var countdown: some View {
        Text(timer.displayTime)
            .font(.system(size: 72, weight: .thin, design: .monospaced))
            .foregroundStyle(theme.foreground)
            .contentTransition(.numericText(countsDown: true))
            .animation(.linear(duration: 0.15), value: timer.displayTime)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(theme.foreground.opacity(0.1))
                    .frame(height: 1)
                Rectangle()
                    .fill(theme.foreground)
                    .frame(width: geo.size.width * timer.progress, height: 1)
                    .animation(.linear(duration: 0.9), value: timer.progress)
            }
        }
        .frame(height: 1)
    }

    private var controls: some View {
        HStack(spacing: 24) {
            ZenithButton(label: "RESET", theme: theme) {
                timer.reset()
            }

            ZenithButton(
                label: timer.isActive ? "PAUSE" : "START",
                theme: theme,
                isPrimary: true
            ) {
                timer.isActive ? timer.pause() : timer.start()
            }

            ZenithButton(label: "SKIP", theme: theme) {
                timer.skipPhase()
            }
        }
    }
}

// MARK: - ZenithButton

private struct ZenithButton: View {
    let label: String
    let theme: ThemeManager
    var isPrimary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(isPrimary ? theme.background : theme.foreground)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isPrimary ? theme.foreground : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(theme.foreground, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isPrimary)
    }
}

// MARK: - Preview

#Preview("Dark") {
    PomodoroView(theme: ThemeManager())
        .frame(width: 400, height: 260)
        .background(Color.black)
}

#Preview("Light") {
    let t = ThemeManager()
    t.isDark = false
    return PomodoroView(theme: t)
        .frame(width: 400, height: 260)
        .background(Color.white)
}
