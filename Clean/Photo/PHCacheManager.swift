//
//  PHCacheManager.swift
//  Clean
//
//  Created by liqi on 2020/10/29.
//

import UIKit
import Photos

class PHCacheManager {
    
    static let cache = PHCachingImageManager()
    
    class func getTargetCellSize() -> CGSize {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let size = screenWidth / 4 * UIScreen.main.scale
        return CGSize(width: size, height: size)
    }
    
    
}
