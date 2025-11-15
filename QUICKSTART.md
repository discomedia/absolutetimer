# Quick Start Guide

Get your Absolute Timer app running in 5 minutes!

## Prerequisites

- macOS with Xcode 15+
- iOS Simulator or iOS device

## Step 1: Add Audio Files (Optional but Recommended)

Download or create two audio files:
- `bell.wav` - A bell sound (~1-2 seconds)
- `warning.wav` - A beep sound (~0.5-1 second)

Quick sources:
- **freesound.org** - Free sound effects
- **GarageBand** - Create custom sounds
- **Online generators** - Search "bell sound generator"

Place them in `AbsoluteTimer/Assets/` folder.

## Step 2: Open in Xcode

```bash
cd /Users/danahooshmand/dev/discomedia/absolutetimer
xed .
```

Wait for Xcode to open and index the project.

## Step 3: Add Audio Files to Project (if you have them)

In Xcode:
1. Right-click on "AbsoluteTimer" folder in navigator
2. Choose "Add Files to AbsoluteTimer..."
3. Select your `bell.wav` and `warning.wav` files
4. Make sure "Copy items if needed" is checked
5. Make sure "AbsoluteTimer" target is selected
6. Click "Add"

## Step 4: Enable Background Audio

In Xcode:
1. Select "AbsoluteTimer" project in navigator (top item)
2. Select "AbsoluteTimer" target
3. Click "Signing & Capabilities" tab
4. Click "+ Capability"
5. Search for and add "Background Modes"
6. Check the box for "Audio, AirPlay, and Picture in Picture"

## Step 5: Configure Signing

In Xcode (Signing & Capabilities tab):
1. Select your Team from the dropdown
2. Xcode will automatically manage signing

## Step 6: Choose Destination

At the top of Xcode:
- For Simulator: Click destination dropdown → Choose "iPhone 15" (or any simulator)
- For Device: Connect your iPhone/iPad → Select it from dropdown

## Step 7: Build & Run

Press ▶️ (or Cmd+R) to build and run!

## Expected Behavior

### On Launch
- App opens with timer showing 03:00
- Black background (idle state)
- "Standard Boxing" profile selected
- Round 1 of 12 displayed

### After Pressing Start
- Background turns green (active round)
- Timer counts down
- Bell sound plays (if audio files added)
- Voice says "Round 1" (if audio files added)

### At 10 Seconds Remaining
- Warning beep plays
- Haptic feedback

### At 00:00
- Bell sound plays
- Background turns red (break period)
- Timer shows 01:00 (break duration)
- Voice says "Break"

### After Break
- Bell sound plays
- Background turns green
- Round 2 starts
- Voice says "Round 2"

## Testing Different Profiles

1. Tap the profile name at top ("Standard Boxing")
2. Select different profile (e.g., "EMOM" for faster testing)
3. Tap outside sheet to close
4. Press Start

## Creating Custom Profile

1. Tap profile name
2. Tap pencil icon (top right)
3. Tap "+ Add Profile"
4. Edit name and durations
5. Tap "Save"
6. Select your new profile from list

## Settings

1. Tap gear icon (top right of timer screen)
2. Toggle options:
   - Sound Effects
   - Voice Announcements
   - Haptic Feedback
3. Tap "Done"

## Troubleshooting

### No Sound
- Check audio files are added to project
- Check device/simulator volume
- Check Sound Effects toggle in Settings
- Ensure Silent mode is off (device only)

### No Voice Announcements
- Check Voice Announcements toggle in Settings
- TTS works even without audio files

### Build Errors
- Clean build: Product → Clean Build Folder (Cmd+Shift+K)
- Restart Xcode
- Check Xcode command line tools: `xcode-select --install`

### Signing Issues
- Select your Team in Signing & Capabilities
- Change Bundle Identifier if needed
- Ensure you have developer account (free is OK)

## Building from Command Line (Advanced)

```bash
# Build for simulator
xcodebuild -scheme AbsoluteTimer -destination 'platform=iOS Simulator,name=iPhone 15'

# Build for device (requires signing configuration)
xcodebuild -scheme AbsoluteTimer -destination 'generic/platform=iOS'

# Run tests
xcodebuild test -scheme AbsoluteTimer

# Clean
xcodebuild clean -scheme AbsoluteTimer
```

## VSCode Development

You can continue editing Swift files in VSCode:

1. Install Swift extension in VSCode
2. Edit any .swift file
3. Build in Xcode or via command line
4. Use Cmd+Shift+B in VSCode to run build task

## What to Test

- ✅ Timer starts, pauses, resumes, resets
- ✅ Round transitions work correctly
- ✅ Break periods work (or skip if break = 0)
- ✅ Final round triggers completion
- ✅ All 4 default profiles work
- ✅ Custom profile creation/editing/deletion
- ✅ Profile selection persists after restart
- ✅ Settings toggles work and persist
- ✅ Audio plays (if files added)
- ✅ Voice announcements work
- ✅ Haptic feedback triggers
- ✅ Background colors change (black/green/red)
- ✅ App works when locked (background audio)

## Next Steps

Once basic testing is complete:
1. Add custom app icon
2. Test on physical device
3. Test background behavior with screen locked
4. Fine-tune audio files
5. Create custom profiles for your workouts

## Need Help?

See full documentation:
- **README.md** - Full project overview
- **IMPLEMENTATION.md** - Detailed implementation checklist
- **BUILD_SUMMARY.md** - What was built
- **SPEC.md** - Original specification

---

**You're all set!** Enjoy your new timer app! 🥊🏃‍♂️
