import Foundation
import os

// MARK: - PomodoroPhase

enum PomodoroPhase: String, Codable {
    case work
    case shortBreak

    var duration: TimeInterval {
        switch self {
        case .work:       return 25 * 60
        case .shortBreak: return  5 * 60
        }
    }

    var label: String {
        switch self {
        case .work:       return "Focus"
        case .shortBreak: return "Break"
        }
    }
}

// MARK: - TimerViewModel

@Observable final class TimerViewModel {

    // MARK: Published state

    private(set) var timeLeft: TimeInterval = PomodoroPhase.work.duration
    private(set) var isActive: Bool = false
    private(set) var currentPhase: PomodoroPhase = .work

    // MARK: Computed helpers

    var displayTime: String {
        let total = Int(timeLeft)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Fraction of the current phase that has elapsed (0.0 at start → 1.0 at completion).
    var progress: Double {
        let elapsed = currentPhase.duration - timeLeft
        return min(max(elapsed / currentPhase.duration, 0.0), 1.0)
    }

    // MARK: Timer infrastructure

    private var dispatchTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(
        label: "com.zenith.timer",
        qos: .utility,
        attributes: [],
        autoreleaseFrequency: .workItem
    )

    private let logger = Logger(subsystem: "com.zenith.app", category: "timer")

    // MARK: Public API

    func start() {
        guard !isActive else { return }

        let source = DispatchSource.makeTimerSource(queue: timerQueue)
        source.schedule(deadline: .now() + 1.0, repeating: 1.0, leeway: .milliseconds(100))
        source.setEventHandler { [weak self] in
            DispatchQueue.main.async { self?.tick() }
        }
        source.resume()

        dispatchTimer = source
        isActive = true
        logger.info("Timer started — phase: \(self.currentPhase.label), timeLeft: \(self.timeLeft)s")
    }

    func pause() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        isActive = false
        logger.info("Timer paused — phase: \(self.currentPhase.label), timeLeft: \(self.timeLeft)s")
    }

    func reset() {
        pause()
        timeLeft = currentPhase.duration
        logger.info("Timer reset — phase: \(self.currentPhase.label), duration: \(self.currentPhase.duration)s")
    }

    func skipPhase() {
        pause()
        advance()
    }

    // MARK: Private

    private func tick() {
        if timeLeft > 0 {
            timeLeft -= 1
        } else {
            advance()
        }
    }

    private func advance() {
        pause()
        currentPhase = (currentPhase == .work) ? .shortBreak : .work
        timeLeft = currentPhase.duration
        logger.info("Phase advanced — now: \(self.currentPhase.label), duration: \(self.currentPhase.duration)s")
    }

    deinit {
        dispatchTimer?.cancel()
        dispatchTimer = nil
    }
}
