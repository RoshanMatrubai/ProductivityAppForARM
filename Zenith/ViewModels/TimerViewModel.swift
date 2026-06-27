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

    // MARK: Persistence keys

    private static let keyTimeLeft  = "timer.timeLeft"
    private static let keyPhase     = "timer.phase"
    private static let keyWasActive = "timer.wasActive"
    private static let keyLastSaved = "timer.lastSaveDate"

    // MARK: Init

    init() {
        restoreState()
    }

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
        saveState()
        logger.info("Timer started — phase: \(self.currentPhase.label), timeLeft: \(self.timeLeft)s")
    }

    func pause() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        isActive = false
        saveState()
        logger.info("Timer paused — phase: \(self.currentPhase.label), timeLeft: \(self.timeLeft)s")
    }

    func reset() {
        pause()
        timeLeft = currentPhase.duration
        saveState()
        logger.info("Timer reset — phase: \(self.currentPhase.label)")
    }

    /// Manual skip — advances phase but leaves timer paused (user decides when to start).
    func skipPhase() {
        pause()
        currentPhase = (currentPhase == .work) ? .shortBreak : .work
        timeLeft = currentPhase.duration
        saveState()
        logger.info("Phase skipped — now: \(self.currentPhase.label)")
    }

    /// Persist current timer state to UserDefaults. Called every tick and on every
    /// state transition so a SIGKILL loses at most ~1 second of timer position.
    func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(timeLeft,               forKey: Self.keyTimeLeft)
        defaults.set(currentPhase.rawValue,  forKey: Self.keyPhase)
        defaults.set(isActive,               forKey: Self.keyWasActive)
        defaults.set(Date(),                 forKey: Self.keyLastSaved)
    }

    // MARK: Private

    private func tick() {
        if timeLeft > 0 {
            timeLeft -= 1
            saveState()
        } else {
            completePhase()
        }
    }

    /// Natural phase completion — auto-starts next phase.
    /// Distinct from skipPhase() which leaves the timer paused.
    private func completePhase() {
        dispatchTimer?.cancel()
        dispatchTimer = nil
        isActive = false
        currentPhase = (currentPhase == .work) ? .shortBreak : .work
        timeLeft = currentPhase.duration
        saveState()
        logger.info("Phase completed — advancing to: \(self.currentPhase.label)")
        start()
    }

    /// Restore timer position from UserDefaults. If the timer was active when the
    /// app was killed, subtract wall-clock elapsed time so the display is accurate.
    /// isActive is NOT restored — user restarts manually after a force-quit relaunch.
    private func restoreState() {
        let defaults = UserDefaults.standard
        let savedTime = defaults.double(forKey: Self.keyTimeLeft)
        guard savedTime > 0 else { return }

        let phaseRaw  = defaults.string(forKey: Self.keyPhase) ?? PomodoroPhase.work.rawValue
        let wasActive = defaults.bool(forKey: Self.keyWasActive)
        let lastSaved = defaults.object(forKey: Self.keyLastSaved) as? Date

        currentPhase = PomodoroPhase(rawValue: phaseRaw) ?? .work

        var restored = savedTime
        if wasActive, let lastSaved {
            let elapsed = Date().timeIntervalSince(lastSaved)
            restored = max(0, savedTime - elapsed)
        }

        timeLeft = restored > 0 ? restored : currentPhase.duration
        logger.info("Timer restored — phase: \(self.currentPhase.label), timeLeft: \(self.timeLeft)s")
    }

    deinit {
        dispatchTimer?.cancel()
        dispatchTimer = nil
    }
}
