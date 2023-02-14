//
//  UIImage+Extension.swift
//  Dingweibao
//
//  Created by LiQi on 2020/5/27.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func create(_ name: String) -> UIImage {
        return UIImage.init(named: name)!
    }
    
    var snpSize: CGSize {
        return .init(width: Float(self.size.width).uiX, height: Float(self.size.height).uiX)
    }
    
    var snpScale: CGFloat {
        let size = snpSize
        if size.width == 0 {
            return 0
        }
        let scale = size.height/size.width
        return scale
    }
}
