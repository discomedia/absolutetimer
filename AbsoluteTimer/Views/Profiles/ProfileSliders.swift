//
//  ProfileSliders.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct ProfileSliders: View {
    @Binding var roundDuration: Int
    @Binding var breakDuration: Int
    @Binding var totalRounds: Int
    
    var body: some View {
        VStack(spacing: 30) {
            // Round Duration
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Round Duration")
                        .font(.headline)
                    Spacer()
                    Text(TimeFormatter.formatTime(roundDuration))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Slider(value: Binding(
                    get: { Double(roundDuration) },
                    set: { roundDuration = Int($0) }
                ), in: 10...600, step: 5)
                
                HStack {
                    QuickTimeButton(time: 30, label: "30s") {
                        roundDuration = $0
                    }
                    QuickTimeButton(time: 45, label: "45s") {
                        roundDuration = $0
                    }
                    QuickTimeButton(time: 60, label: "1m") {
                        roundDuration = $0
                    }
                    QuickTimeButton(time: 120, label: "2m") {
                        roundDuration = $0
                    }
                    QuickTimeButton(time: 180, label: "3m") {
                        roundDuration = $0
                    }
                    QuickTimeButton(time: 300, label: "5m") {
                        roundDuration = $0
                    }
                }
            }
            
            // Break Duration
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Break Duration")
                        .font(.headline)
                    Spacer()
                    Text(TimeFormatter.formatTime(breakDuration))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Slider(value: Binding(
                    get: { Double(breakDuration) },
                    set: { breakDuration = Int($0) }
                ), in: 0...300, step: 5)
                
                HStack {
                    QuickTimeButton(time: 0, label: "None") {
                        breakDuration = $0
                    }
                    QuickTimeButton(time: 30, label: "30s") {
                        breakDuration = $0
                    }
                    QuickTimeButton(time: 45, label: "45s") {
                        breakDuration = $0
                    }
                    QuickTimeButton(time: 60, label: "1m") {
                        breakDuration = $0
                    }
                    QuickTimeButton(time: 90, label: "90s") {
                        breakDuration = $0
                    }
                }
            }
            
            // Total Rounds
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Total Rounds")
                        .font(.headline)
                    Spacer()
                    Text("\(totalRounds)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Slider(value: Binding(
                    get: { Double(totalRounds) },
                    set: { totalRounds = Int($0) }
                ), in: 1...50, step: 1)
                
                HStack {
                    QuickTimeButton(time: 3, label: "3") {
                        totalRounds = $0
                    }
                    QuickTimeButton(time: 5, label: "5") {
                        totalRounds = $0
                    }
                    QuickTimeButton(time: 10, label: "10") {
                        totalRounds = $0
                    }
                    QuickTimeButton(time: 12, label: "12") {
                        totalRounds = $0
                    }
                    QuickTimeButton(time: 20, label: "20") {
                        totalRounds = $0
                    }
                }
            }
        }
    }
}

struct QuickTimeButton: View {
    let time: Int
    let label: String
    let action: (Int) -> Void
    
    var body: some View {
        Button(action: {
            Haptics.shared.light()
            action(time)
        }) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
        }
    }
}

#Preview {
    ProfileSliders(
        roundDuration: .constant(180),
        breakDuration: .constant(60),
        totalRounds: .constant(12)
    )
    .padding()
}
