//
//  EKAttributes+Extensions.swift
//  DFGithub
//
//  Created by David FU on 2025/5/11.
//

import SwiftEntryKit

public extension EKAttributes.PositionConstraints {
    
    /** A full screen entry - fills the entire screen, modal-like */
    static var fullScreen2: EKAttributes.PositionConstraints {
        var ret = EKAttributes.PositionConstraints(verticalOffset: 0, size: .screen)
        ret.safeArea = .overridden
        return ret
    }
    
}

public extension EKAttributes {
    
    /** Toast preset - The frame fills margins and safe area is filled with background view */
    static var presentOverFullScreen: EKAttributes {
        var attributes = EKAttributes()
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.precedence = .enqueue(priority: .normal)
        attributes.displayDuration = .infinity
        attributes.positionConstraints = .fullScreen2
        
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.hapticFeedbackType = .success
        attributes.lifecycleEvents = LifecycleEvents()
        return attributes
    }
}
