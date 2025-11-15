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
        impactLight.impactOccurred()
    }
    
    func medium() {
        impactMedium.impactOccurred()
    }
    
    func heavy() {
        impactHeavy.impactOccurred()
    }
    
    func success() {
        notification.notificationOccurred(.success)
    }
    
    func warning() {
        notification.notificationOccurred(.warning)
    }
    
    func error() {
        notification.notificationOccurred(.error)
    }
}
