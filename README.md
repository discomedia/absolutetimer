# Absolute Timer

A native iOS application for boxing, MMA, and HIIT training built with SwiftUI. Provides customizable round timers, break timers, audio cues, text-to-speech announcements, and profile management.

## Features

### Core Timer
- High-precision timer with 0.1s accuracy
- Visual feedback with color-coded backgrounds:
  - **Black**: Idle state
  - **Green**: Active round
  - **Red**: Break period
- Large, easy-to-read MM:SS display
- Round counter showing current round and total
- Auto-switch between rounds and breaks
- Completion detection with haptic feedback

### Audio & Feedback
- Bell sounds for round start/end
- Warning beep at 10 seconds before round end
- Text-to-speech announcements:
  - "Round X" at the start of each round
  - "Final Round" for the last round
  - "Break" during rest periods
  - "Time" when workout completes
- Haptic feedback for key events
- Keeps the screen awake while an active timer is running

### Profiles
- **4 Default Profiles**:
  - Standard Boxing: 3min rounds × 12, 1min break
  - Standard MMA: 5min rounds × 5, 1min break
  - EMOM: 1min rounds × 20, no break
  - E2MOM: 2min rounds × 10, no break
- Create custom profiles with:
  - Custom name
  - Round duration (10s - 10min)
  - Break duration (0s - 5min)
  - Total rounds (1 - 50)
- Quick preset buttons for common durations
- Save and delete custom profiles
- Profiles persist across app launches

### Settings
- Toggle sound effects on/off
- Toggle voice announcements on/off
- Toggle haptic feedback on/off
- Settings saved automatically

## Project Structure

```
AbsoluteTimer/
├── Models/
│   ├── TimerProfile.swift          # Profile data model
│   └── TimerState.swift            # Timer state tracking
├── ViewModels/
│   ├── TimerViewModel.swift        # Timer logic & state management
│   ├── ProfilesViewModel.swift    # Profile management
│   └── SettingsViewModel.swift    # App settings
├── Views/
│   ├── Timer/
│   │   ├── TimerScreen.swift       # Main timer screen
│   │   ├── TimerDisplay.swift      # Time & round display
│   │   ├── TimerControls.swift     # Start/Pause/Reset buttons
│   │   └── TimerBackground.swift   # Animated background colors
│   ├── Profiles/
│   │   ├── ProfileSelector.swift   # Select active profile
│   │   ├── ProfileEditor.swift     # Create/edit profiles
│   │   ├── ProfileSliders.swift    # Duration/round sliders
│   │   └── ProfileManager.swift    # Manage all profiles
│   └── Settings/
│       └── SettingsScreen.swift    # App settings
├── Services/
│   ├── AudioService.swift          # Sound effects playback
│   ├── SpeechService.swift         # Text-to-speech
│   ├── ProfileStorage.swift        # Profile persistence
│   └── Haptics.swift               # Haptic feedback
├── Utils/
│   ├── TimeFormatter.swift         # Time formatting helpers
│   └── DefaultProfiles.swift       # Built-in profiles
└── PrivacyInfo.xcprivacy           # App Store privacy manifest
```

## Development Setup

### Prerequisites
- macOS with Xcode 15+
- iOS 17.0+ SDK
- Swift 6

### VSCode Development (Recommended)

This project is designed to be developed primarily in VSCode.

#### Required Extensions
- Swift (official Swift Server Workgroup)
- SourceKit-LSP (built into Swift extension)

#### Building in VSCode
```bash
# Build the project
xcodebuild -scheme AbsoluteTimer

# Build for simulator
xcodebuild -scheme AbsoluteTimer -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -scheme AbsoluteTimer
```

You can also add a build task to `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build App",
      "type": "shell",
      "command": "xcodebuild -scheme AbsoluteTimer",
      "problemMatcher": "$gcc"
    }
  ]
}
```

Then press `Cmd+Shift+B` to build.

### Using Xcode

While development is done in VSCode, Xcode is still needed for:
- Running on simulator or device
- Managing signing & provisioning
- Archiving & uploading to App Store

To open in Xcode:
```bash
xed .
```

## Audio

The app uses system sound cues for round and warning alerts plus `AVSpeechSynthesizer` for voice announcements. No bundled audio files are required for v1.

## App Store Assets

App Store metadata, privacy/support page drafts, and 6.9-inch iPhone screenshots are in `app-store/`.

### App Icon

Replace the placeholder in `Assets.xcassets/AppIcon.appiconset/` with your app icon.

## Architecture

### MVVM Pattern
- **Models**: Data structures (TimerProfile, TimerState)
- **ViewModels**: Business logic and state management
- **Views**: SwiftUI components for UI
- **Services**: Reusable services (audio, storage, haptics)

### State Management
- `@StateObject` for view model ownership
- `@EnvironmentObject` for shared services
- `UserDefaults` for settings and profile persistence
- `Combine` for timer events

### Timer Implementation
- Uses `Timer.publish` with 0.1s intervals for high precision
- Prevents screen dimming during active sessions

## Building for Release

1. Open in Xcode: `xed .`
2. Select "Any iOS Device" as destination
3. Product → Archive
4. Distribute via App Store Connect
5. Submit for TestFlight/App Store review

## Performance Targets

| Metric         | Target |
| -------------- | ------ |
| Timer accuracy | ± 10ms |
| Audio latency  | < 30ms |
| App launch     | < 1.5s |
| Memory usage   | < 30MB |

## License

Copyright © 2025 Dana Hooshmand. All rights reserved.

## Support

For issues or feature requests, email support@discomedia.com.au.
