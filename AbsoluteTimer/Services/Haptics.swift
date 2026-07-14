//
//  Haptics.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import UIKit

class Haptics {
    static let shared = Haptics()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
    }
    
    func light() {
        guard AppSettings.hapticsEnabled else { return }
        impactLight.impactOccurred()
    }
    
    func medium() {
        guard AppSettings.hapticsEnabled else { return }
        impactMedium.impactOccurred()
    }
    
    func heavy() {
        guard AppSettings.hapticsEnabled else { return }
        impactHeavy.impactOccurred()
    }
    
    func success() {
        guard AppSettings.hapticsEnabled else { return }
        notification.notificationOccurred(.success)
    }
    
    func warning() {
        guard AppSettings.hapticsEnabled else { return }
        notification.notificationOccurred(.warning)
    }
    
    func error() {
        guard AppSettings.hapticsEnabled else { return }
        notification.notificationOccurred(.error)
    }
}
