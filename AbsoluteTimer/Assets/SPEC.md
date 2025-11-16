Absolute Timer — Native Swift (SwiftUI) Application Specification

Absolute Timer is a native iOS application for boxing, MMA, and HIIT training.
It provides customizable round timers, break timers, audio cues, text-to-speech announcements, and profile management.
The goal is simplicity, reliability, and ultra-low latency audio cues while maintaining a clean SwiftUI codebase.

This specification defines:
	•	All features
	•	Architecture
	•	File structure
	•	Data models
	•	Audio and background behavior
	•	VSCode-based workflow
	•	Build and deployment steps
	•	Performance targets

⸻

1. Development Workflow (VSCode-First)

1.1 Work in VSCode

You will write all Swift code inside VSCode, not Xcode.

Required VSCode Extensions:
	•	Swift (official Swift Server Workgroup)
	•	SourceKit-LSP (built into Swift extension)
	•	Swift-Format
	•	Error Lens (optional)
	•	GitLens (optional)

Recommended settings (settings.json):

{
  "swift.formatting.provider": "swift-format",
  "editor.defaultFormatter": "swift.swift-lang",
  "editor.formatOnSave": true,
  "swift.suppressNonProjectDiagnostics": false
}

Optional VSCode build task (.vscode/tasks.json):

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

You can now press Cmd+Shift+B to build via VSCode.

⸻

1.2 Use Xcode Only When Necessary

Xcode is required only for:
	•	Creating the initial project
	•	Running on simulator or device
	•	Managing signing & provisioning
	•	Adding entitlements (e.g., Background Audio)
	•	Archiving & uploading to App Store

Run Xcode from the terminal:

xed .


⸻

1.3 Command-Line Builds

Build for simulator:

xcodebuild -scheme AbsoluteTimer -destination 'platform=iOS Simulator,name=iPhone 15'

Run tests:

xcodebuild test -scheme AbsoluteTimer


⸻

1.4 Creating a New App (initial setup)
	1.	Open Xcode → “New Project”
	2.	Template: iOS App
	3.	Interface: SwiftUI
	4.	Save project
	5.	Close Xcode
	6.	Open project in VSCode:

code .


⸻

2. Tech Stack

2.1 Language & Framework
	•	Swift 6
	•	SwiftUI for UI
	•	Combine for reactive timer state
	•	Foundation for data models and persistence

2.2 Local Storage
	•	Default profiles embedded in bundle
	•	User-created profiles stored as JSON in app documents
	•	Quick settings stored in UserDefaults
	•	Optional: @AppStorage and @SceneStorage

2.3 Audio
	•	AVSpeechSynthesizer for all announcements and most cues (system voices)
	•	System haptics via UIImpactFeedbackGenerator/CoreHaptics for tactile cues
	•	Optional: AudioServicesPlaySystemSound for brief system-provided tones (no bundled files)

2.4 Haptics
	•	UIImpactFeedbackGenerator
	•	Optional: CoreHaptics for rhythmic custom patterns
	•	Prefer pairing haptics with TTS for critical cues

⸻

3. Project Structure

AbsoluteTimer/
├── AbsoluteTimerApp.swift          # App entry
├── Models/
│   ├── TimerProfile.swift
│   └── TimerState.swift
├── ViewModels/
│   ├── TimerViewModel.swift
│   ├── ProfilesViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Timer/
│   │   ├── TimerScreen.swift
│   │   ├── TimerDisplay.swift
│   │   ├── TimerControls.swift
│   │   └── TimerBackground.swift
│   ├── Profiles/
│   │   ├── ProfileSelector.swift
│   │   ├── ProfileEditor.swift
│   │   ├── ProfileSliders.swift
│   │   └── ProfileManager.swift
│   └── Settings/
│       └── SettingsScreen.swift
├── Services/
│   ├── AudioService.swift
│   ├── SpeechService.swift
│   ├── ProfileStorage.swift
│   └── Haptics.swift
├── Utils/
│   ├── TimeFormatter.swift
│   └── DefaultProfiles.swift
└── Assets/
    └── AppIcon.appiconset


⸻

4. Data Models

4.1 TimerProfile

struct TimerProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var roundDuration: Int
    var breakDuration: Int
    var totalRounds: Int
    var isDefault: Bool
}

4.2 TimerState

struct TimerState {
    var currentRound: Int = 1
    var timeRemaining: Int = 0
    var isActive: Bool = false
    var isRoundActive: Bool = true
    var isCompleted: Bool = false
}


⸻

5. UI Specification

5.1 Main Timer Screen

Background Color Logic
	•	Idle: Black
	•	Round (running): Green (#22c55e)
	•	Break (running): Red (#dc2626)
	•	Paused (during round or break): Yellow (#f59e0b)

UI Elements
	•	Large MM:SS display
	•	“Round X of Y”
	•	Start / Pause / Resume / Reset buttons
	•	Profile selector is hidden once the timer has started and remains hidden while running, paused, and after completion; it only reappears after Reset
	•	Background color matched to current state
	•	Screen stays awake during timer

Timer Behavior
	•	High-precision 0.1s tick using Timer.publish
	•	Auto switch between Round → Break
	•	After final round: completion mode + haptic
	•	Audio feedback throughout
	•	Supports app backgrounding
	•	When paused, background turns yellow and the profile selector remains hidden until Reset

⸻

6. Profiles

6.1 Default Profiles

let defaultProfiles: [TimerProfile] = [
    .init(id: UUID(), name: "Standard Boxing",
          roundDuration: 180, breakDuration: 60, totalRounds: 12, isDefault: true),
    .init(id: UUID(), name: "Standard MMA",
          roundDuration: 300, breakDuration: 60, totalRounds: 5, isDefault: true),
    .init(id: UUID(), name: "EMOM",
          roundDuration: 60, breakDuration: 0, totalRounds: 20, isDefault: true),
    .init(id: UUID(), name: "E2MOM",
          roundDuration: 120, breakDuration: 0, totalRounds: 10, isDefault: true)
]

6.2 Profile Selector
	•	SwiftUI Picker
	•	Defaults on top
	•	User-created profiles below
	•	Last selected profile stored in UserDefaults

6.3 Profiles Screen
	•	List of all profiles
	•	Swipe to delete (custom profiles only)
	•	“Add New Profile” button

6.4 Profile Editor
	•	Name
	•	Round slider
	•	Break slider
	•	Total rounds slider
	•	Preset values (30s, 45s, 1m, etc.)
	•	Validation
	•	Haptic feedback on save

6.5 Migration Notes (No External Audio Files)
- Remove any references to bell.wav and warning.wav in code and assets.
- Update AudioService to use AVSpeechSynthesizer and/or AudioServicesPlaySystemSound.
- Ensure graceful degradation to TTS-only if system tones are unavailable.
- QA: Verify no runtime log mentions missing sound files; verify voice selection fallback works even if voice enumeration fails.


⸻

7. Audio & Voice System Specification

7.1 Guiding Principle
- Use only system-provided capabilities. Do not bundle external audio assets (no .wav/.mp3 in the app bundle).
- Prefer AVSpeechSynthesizer for all voice announcements and short cues where feasible.
- Where a non-voice cue is desired, use system-provided haptics and system sound services rather than custom files.

7.2 Sound Effects (No Bundled Files)
- Round start cue: Use a system sound (AudioServicesPlaySystemSound with a documented system sound ID) or a short TTS phoneme cue (e.g., "ding") with a distinct voice/phrase.
- Round end cue: Same approach as round start.
- Break cue: Use a different system sound or a spoken word (e.g., "Break") via TTS.
- Warning cue (e.g., 10s before end): Use haptics and/or a brief TTS phrase (e.g., "Ten seconds").

Implementation Notes:
- Prefer haptic + TTS combinations to ensure accessibility and reliability.
- Avoid AVAudioPlayer for file-backed playback; no reliance on bundled audio assets.
- If system sound IDs are used, ensure they are available on iOS and gracefully degrade to TTS-only if unavailable.

7.3 Text-to-Speech (System Voices Only)
- Use AVSpeechSynthesizer exclusively for announcements.
- Select from system voices (AVSpeechSynthesisVoice.speechVoices()). Do not download or bundle custom voices.
- Provide a fallback strategy if voice enumeration fails:
  - Use AVSpeechSynthesisVoice(language: Locale.current.identifier) if available.
  - Else fall back to the default voice (nil voice).
- Announcements:
  - "Round X"
  - "Final Round"
  - "Break"
  - Optional: "Time"

7.4 Background Audio
- Enable Audio background mode.
- Ensure TTS continues in background where appropriate.
- Timer continues when device is locked.

7.5 Error Handling & Diagnostics
- If voice enumeration throws decoding errors, log once per session and switch to default voice without crashing.
- If system sound playback is unavailable, automatically switch to TTS-only cues + haptics.
- Avoid references to missing files; there should be no lookups for bell.wav or warning.wav.

⸻

8. Platform Features (iOS)
	•	Background audio
	•	Haptics
	•	Dark Mode support
	•	Portrait orientation lock
	•	Screen-wake disabled during sessions
	•	Control Center audio handling
	•	Volume button integration (optional)
	•	No bundled audio assets; relies on system voices, haptics, and system sounds

⸻

9. Permissions
	•	No microphone permission needed
	•	Background Modes → Audio
	•	Disable Auto-Lock when timer is active

⸻

10. Deployment

10.1 Development Environment

Use VSCode for everything except device/simulator builds.

Building and Running:

xed .   # opens Xcode

Then press ▶️ Run.

10.2 App Store Submission

Steps handled in Xcode:
	1.	Archive build (Product → Archive)
	2.	Distribute via App Store Connect
	3.	TestFlight testing
	4.	App Store review (1–7 days)

⸻

11. Performance Metrics

Metric	Target
Timer accuracy	± 10ms
Audio latency	< 30ms (Measured using TTS start latency and/or system sound dispatch; no file I/O)
App launch	< 1.5s
Memory usage	< 30MB
Battery	Minimal drain with background audio


⸻

12. Development Timeline

Phase 1 (Weeks 1–2): Core Timer
	•	TimerViewModel
	•	TimerScreen
	•	Background colors
	•	Navigation
	•	Default profiles

Phase 2 (Week 3): Audio
	•	Bell sounds
	•	Warning beeps
	•	TTS announcements
	•	Background audio

Phase 3 (Week 4): Profiles
	•	Editor screen
	•	Profile storage
	•	Sliders and validation
	•	JSON persistence

Phase 4 (Weeks 5–6): Polish
	•	Haptics
	•	Dark Mode audit
	•	Screen awake
	•	Settings screen

Phase 5 (Week 7): Deployment
	•	TestFlight
	•	Bug fixes
	•	App Store submission

⸻

13. Success Criteria
	•	Start workout in a single tap
	•	Reliable audio cues
	•	Zero timing drift
	•	Stable in background
	•	Clean SwiftUI architecture
	•	4.5+ App Store rating target



