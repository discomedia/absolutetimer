//
//  TimerControls.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct TimerControls: View {
    let isActive: Bool
    let isCompleted: Bool
    let hasStarted: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            if !isActive && !isCompleted {
                Button(action: {
                    Haptics.shared.light()
                    onStart()
                }) {
                    Label(hasStarted ? "Resume" : "Start", systemImage: "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                }
            } else if isActive {
                Button(action: {
                    Haptics.shared.light()
                    onPause()
                }) {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                }
            }
            
            Button(action: {
                Haptics.shared.light()
                onReset()
            }) {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.green
        VStack {
            TimerControls(
                isActive: false,
                isCompleted: false,
                hasStarted: false,
                onStart: {},
                onPause: {},
                onReset: {}
            )
            
            TimerControls(
                isActive: true,
                isCompleted: false,
                hasStarted: true,
                onStart: {},
                onPause: {},
                onReset: {}
            )
        }
    }
}
