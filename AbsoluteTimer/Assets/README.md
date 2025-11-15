# Audio Assets

This directory should contain the following audio files for the timer:

## Required Files

1. **bell.wav** - Bell sound for round start/end
   - Format: WAV or MP3
   - Duration: ~1-2 seconds
   - Use: Played at the start and end of each round

2. **warning.wav** - Warning beep for 10-second countdown
   - Format: WAV or MP3
   - Duration: ~0.5-1 second
   - Use: Played 10 seconds before the end of a round

## Where to Get Sounds

You can:
- Use royalty-free sounds from freesound.org
- Record your own sounds
- Generate simple tones using audio software
- Purchase from sound libraries

## Adding to Xcode

1. Open the project in Xcode: `xed .`
2. Drag the audio files into the Assets.xcassets folder
3. Or add them to the project navigator and ensure they're included in the target

## Note

The app currently references these files in `AudioService.swift`. If the files are not present, the app will still run but sounds won't play (errors will be logged to console).
