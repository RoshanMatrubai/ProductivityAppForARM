# Zenith

Minimalist ARM-native productivity for macOS. A Pomodoro timer and click-to-strikethrough task list in a strictly black-and-white interface — no Electron, no web views, near-zero idle energy impact.

## Requirements

- macOS 14.0+
- Apple Silicon (ARM64)
- Xcode 16+

## Build & Run

```bash
# Debug build
xcodebuild -scheme Zenith -configuration Debug build

# Launch
open build/Debug/Zenith.app

# Release build (whole-module optimization, hardened runtime)
xcodebuild -scheme Zenith -configuration Release build

# Tests
xcodebuild test -scheme Zenith -destination 'platform=macOS'

# Lint
swiftlint lint --strict
```

## Architecture

| Layer       | Decision                                                                 |
|-------------|--------------------------------------------------------------------------|
| Language    | Swift 5.10+                                                              |
| UI          | SwiftUI — native rendering, hardware-accelerated animations              |
| Pattern     | MVVM with `ObservableObject` / `@Published`                              |
| Persistence | SwiftData (SQLite-backed, no iCloud)                                     |
| Timer       | `DispatchSourceTimer` on `.utility` background queue — main thread idle  |
| Theming     | `ObservableObject` ThemeManager, `@AppStorage` for light/dark preference |
| Target      | macOS 14.0 · ARM64 explicit                                              |

## Features

- **Pomodoro Timer** — 25 min work / 5 min break cycle with progress arc. Background timer never touches the main thread.
- **Task List** — Add tasks, click to toggle completion with animated strikethrough. SwiftData persists every mutation instantly.
- **Task Metadata** — Right-click any task to set priority (Low / Medium / High) or a due date. Priority renders as a small dot (opacity = urgency). Due dates show inline; past-due incomplete tasks show "Overdue".
- **Smart Sort** — Incomplete tasks float to the top sorted by due date (soonest first, undated last), then creation time. Completed tasks sink to the bottom.
- **Multi-Theme Palette** — Five themes (Obsidian, Paper, Crème, Slate, Sepia) selectable from a swatch strip. Preference persists via `@AppStorage`.
- **Force-quit safe** — SQLite file survives a kill-9. Timer state is written to `UserDefaults` every tick and restored with elapsed-time compensation on relaunch.

## Project Structure

```
Zenith/
├── App/            ZenithApp.swift (entry point, ModelContainer)
├── Views/          ContentView, PomodoroView, TaskListView, TaskRowView
├── ViewModels/     TimerViewModel (DispatchSourceTimer, phase logic)
├── Models/         TaskItem (@Model — title, isCompleted, priorityRaw: Int16, dueDate: Date?)
├── Managers/       ThemeManager (ObservableObject)
└── Resources/      Assets.xcassets (AppIcon — black/white Z lettermark)
```

## Demo (≈90s)

1. Launch `Zenith.app` from the Dock.
2. Toggle theme — entire UI flips instantly.
3. Type a task, press Enter.
4. Click the task — animated strikethrough.
5. Press Start on the Pomodoro — timer counts down from 25:00.
6. Force-quit via Activity Monitor (⌘⌥Esc).
7. Relaunch — task still crossed out, mode remembered, timer resumes.

## Energy

Profile with Xcode Instruments → Energy Log. At idle (timer paused, no interaction) the app shows < 0.1 W energy impact on M4. The `DispatchSourceTimer` fires at most once per second during an active session and suspends completely when paused.
