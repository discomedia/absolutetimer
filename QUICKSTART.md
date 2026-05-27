# Quick Start Guide

Get your Absolute Timer app running in 5 minutes!

## Prerequisites

- macOS with Xcode 15+
- iOS Simulator or iOS device

## Step 1: Open in Xcode

```bash
cd /Users/danahooshmand/dev/discomedia/absolutetimer
xed .
```

Wait for Xcode to open and index the project.

## Step 2: Configure Signing

In Xcode (Signing & Capabilities tab):
1. Select your Team from the dropdown
2. Xcode will automatically manage signing

## Step 3: Choose Destination

At the top of Xcode:
- For Simulator: Click destination dropdown → Choose "iPhone 15" (or any simulator)
- For Device: Connect your iPhone → Select it from dropdown

## Step 4: Build & Run

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
- System sound cue plays
- Voice says "Round 1" if Voice Announcements are enabled

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
- Check device/simulator volume
- Check Sound Effects toggle in Settings
- Ensure Silent mode is off (device only)

### No Voice Announcements
- Check Voice Announcements toggle in Settings
- TTS does not require bundled audio files

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
- ✅ Screen stays awake while the timer is actively running

## Next Steps

Once basic testing is complete:
1. Test on physical device
2. Verify App Store privacy/support links
3. Create custom profiles for your workouts

## Need Help?

See full documentation:
- **README.md** - Full project overview
- **IMPLEMENTATION.md** - Detailed implementation checklist
- **BUILD_SUMMARY.md** - What was built
- **SPEC.md** - Original specification

---

**You're all set!** Enjoy your new timer app! 🥊🏃‍♂️
