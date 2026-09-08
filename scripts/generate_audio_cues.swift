#!/usr/bin/env swift

import Foundation

let sampleRate = 44_100
let outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("AbsoluteTimer/Sounds", isDirectory: true)

struct Segment {
    let frequency: Double
    let duration: Double
    let amplitude: Double
}

func appendInteger<T: FixedWidthInteger>(_ value: T, to data: inout Data) {
    var littleEndian = value.littleEndian
    withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
}

func makeWave(segments: [Segment]) -> Data {
    var samples: [Int16] = []

    for segment in segments {
        let count = Int(segment.duration * Double(sampleRate))
        for index in 0..<count {
            if segment.frequency == 0 {
                samples.append(0)
                continue
            }

            let time = Double(index) / Double(sampleRate)
            let edge = min(1, min(time / 0.008, (segment.duration - time) / 0.012))
            let value = sin(2 * Double.pi * segment.frequency * time) * segment.amplitude * max(0, edge)
            samples.append(Int16(max(-1, min(1, value)) * Double(Int16.max)))
        }
    }

    let byteCount = UInt32(samples.count * MemoryLayout<Int16>.size)
    var data = Data("RIFF".utf8)
    appendInteger(UInt32(36) + byteCount, to: &data)
    data.append(Data("WAVEfmt ".utf8))
    appendInteger(UInt32(16), to: &data)
    appendInteger(UInt16(1), to: &data)
    appendInteger(UInt16(1), to: &data)
    appendInteger(UInt32(sampleRate), to: &data)
    appendInteger(UInt32(sampleRate * 2), to: &data)
    appendInteger(UInt16(2), to: &data)
    appendInteger(UInt16(16), to: &data)
    data.append(Data("data".utf8))
    appendInteger(byteCount, to: &data)
    for sample in samples { appendInteger(sample, to: &data) }
    return data
}

let cues: [String: [Segment]] = [
    "countdown.wav": [Segment(frequency: 720, duration: 0.15, amplitude: 0.82)],
    "start.wav": [Segment(frequency: 1_180, duration: 0.30, amplitude: 0.92)],
    "warning-double.wav": [
        Segment(frequency: 880, duration: 0.16, amplitude: 0.98),
        Segment(frequency: 0, duration: 0.09, amplitude: 0),
        Segment(frequency: 880, duration: 0.16, amplitude: 0.98)
    ],
    "bell.wav": [
        Segment(frequency: 880, duration: 0.12, amplitude: 0.90),
        Segment(frequency: 1_320, duration: 0.28, amplitude: 0.84)
    ]
]

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
for (name, segments) in cues {
    try makeWave(segments: segments).write(to: outputDirectory.appendingPathComponent(name))
}

print("Generated \(cues.count) audio cues in \(outputDirectory.path)")
