//
//  PhotoModel.swift
//  Clean
//
//  Created by liqi on 2020/10/28.
//

import Photos
import RxSwift
import RxCocoa
import CoreLocation

extension PhotoModel {
    
    enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
    
    enum SelectedType {
//        case none
        case selected
        case deselected
    }
    
}

class PhotoModel: NSObject {

    let ident: String
    
    var isFromLocal = false
    var thumbImage: UIImage?
    var localURL: URL?
    var address: String?
    
    let asset: PHAsset
    
    var dataLength = 0
    
    var type: MediaType = .unknown
    
    var duration: String = ""
    
    var selectedType = BehaviorRelay<SelectedType>(value: .deselected)
    
    var editImage: UIImage?
    
    var second: Int {
        guard type == .video else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    var whRatio: CGFloat {
        return CGFloat(self.asset.pixelWidth) / CGFloat(self.asset.pixelHeight)
    }
    
    var previewSize: CGSize {
        let scale: CGFloat = 2 //UIScreen.main.scale
        if self.whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, 600) * scale
            let w = h * self.whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, 600) * scale
            let h = w / self.whRatio
            return CGSize(width: w, height: h)
        }
    }
    
    init(asset: PHAsset) {
        self.ident = asset.localIdentifier
        self.asset = asset
        super.init()
        
        self.type = self.transformAssetType(for: asset)
        if self.type == .video {
            self.duration = self.transformDuration(for: asset)
        }
    }
    
    func transformAssetType(for asset: PHAsset) -> PhotoModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return .gif
            }
            if #available(iOS 9.1, *) {
                if asset.mediaSubtypes == .photoLive || asset.mediaSubtypes.rawValue == 10 {
                    return .livePhoto
                }
            }
            return .image
        default:
            return .unknown
        }
    }
    
    func transformDuration(for asset: PHAsset) -> String {
        let dur = Int(round(asset.duration))
        
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
}

func ==(lhs: PhotoModel, rhs: PhotoModel) -> Bool {
    return lhs.ident == rhs.ident
}
