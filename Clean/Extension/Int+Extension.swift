//
//  Int+Extension.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/2/6.
//  Copyright © 2020 长沙奇热. All rights reserved.
//

import UIKit

extension Int {
    
    var uiX: CGFloat {
        return CGFloat(self) * UIDevice.uiXScale
    }
    
    var uiY: CGFloat {
        return CGFloat(self) * UIDevice.uiYScale
    }
}

extension Int {
    
    var price: String {
        if self <= 10000 {
            return "\(self)"
        }
        let n = NumberFormatter()
        n.maximumFractionDigits = 2
        let s = n.string(from: NSNumber(value: Float(self)/1000))
        return "\(s ?? "0")k"
    }
    
    var cash: String {
        let n = NumberFormatter()
        n.minimumFractionDigits = 0
        n.maximumFractionDigits = 2
        let s = n.string(from: NSNumber(value: Float(self)/10000))
        return "\(s ?? "0")"
    }
    
    var cashDigits: String {
        let n = NumberFormatter()
        n.maximumFractionDigits = 2
        n.minimumFractionDigits = 2
        let s = n.string(from: NSNumber(value: Float(self)/10000))
        return "\(s ?? "0")"
    }
}
