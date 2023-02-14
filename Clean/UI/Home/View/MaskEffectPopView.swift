//
//  MaskEffectPopView.swift
//  Clean
//
//  Created by liqi on 2020/10/31.
//

import SwiftEntryKit

class MaskEffectPopView: UIView {
    
    // MARK: - Show
    
    func show() {
        
        var attributes = EKAttributes.centerFloat
        
        attributes.screenBackground = .visualEffect(style: .standard)
        attributes.entryBackground = .color(color: .init(.init(hex: "#F7F7F7")))
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.displayDuration = .infinity
        
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        
        SwiftEntryKit.display(entry: self, using: attributes)
    }
    
    func hide() {
        SwiftEntryKit.dismiss()
    }
    
}
