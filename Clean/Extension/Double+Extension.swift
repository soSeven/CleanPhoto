//
//  Double+Extension.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/8/7.
//  Copyright © 2020 LQ. All rights reserved.
//

import UIKit

extension Double {
    
    var uiX: CGFloat {
        return CGFloat(self) * UIDevice.uiXScale
    }
}
