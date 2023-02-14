//
//  Rect+Extension.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/8/7.
//  Copyright © 2020 LQ. All rights reserved.
//

import UIKit

extension CGRect {
    
    static func xRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height).uiX
    }
    
    static func yRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height).uiY
    }
    
    var uiX: CGRect {
        return .init(
            x: origin.x.uiX,
            y: origin.y.uiX,
            width: size.width.uiX,
            height: size.height.uiX
        )
    }
    
    var uiY: CGRect {
        return .init(
            x: origin.x.uiY,
            y: origin.y.uiY,
            width: size.width.uiY,
            height: size.height.uiY
        )
    }
}
