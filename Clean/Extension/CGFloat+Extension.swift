//
//  CGFloat+Extension.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/8/7.
//  Copyright © 2020 LQ. All rights reserved.
//

import UIKit

extension CGFloat {
    
    var uiX: CGFloat {
        return self * UIDevice.uiXScale
    }
    
    var uiY: CGFloat {
        return self * UIDevice.uiYScale
    }
}

