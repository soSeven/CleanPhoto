//
//  PhotoHelper.swift
//  Clean
//
//  Created by liqi on 2020/10/28.
//

import UIKit
import Photos

class PhotoHelper {
    
    class func fetchVideo(for asset: PHAsset, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion: @escaping ( (AVPlayerItem?, [AnyHashable: Any]?, Bool) -> Void )) -> PHImageRequestID {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        return PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { (item, info) in
            // iOS11 系统这个回调没有在主线程
            DispatchQueue.main.async {
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                completion(item, info, isDegraded)
            }
        }
    }
    
    class func fetchLivePhoto(for asset: PHAsset, completion: @escaping ( (PHLivePhoto?, [AnyHashable: Any]?, Bool) -> Void )) -> PHImageRequestID {
        let option = PHLivePhotoRequestOptions()
        option.version = .current
        option.deliveryMode = .opportunistic
        option.isNetworkAccessAllowed = true
        
        return PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (livePhoto, info) in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            completion(livePhoto, info, isDegraded)
        }
    }
    
    @discardableResult
    class func fetchImage(for asset: PHAsset, size: CGSize, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion: @escaping ( (UIImage?, Bool) -> Void )) -> PHImageRequestID {
        return self.fetchImage(for: asset, size: size, resizeMode: .fast, progress: progress, completion: completion)
    }
    
    @discardableResult
    class func fetchOriginalImageData(for asset: PHAsset, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion: @escaping ( (Data, [AnyHashable: Any]?, Bool) -> Void)) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            option.version = .original
        }
        option.isNetworkAccessAllowed = true
        option.resizeMode = .fast
        option.deliveryMode = .highQualityFormat
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        return PHImageManager.default().requestImageData(for: asset, options: option) { (data, _, _, info) in
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if !cancel, let data = data {
                completion(data, info, isDegraded)
            }
        }
    }
    
    private class func fetchImage(for asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion: @escaping ( (UIImage?, Bool) -> Void )) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        /**
         resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
         deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
         这个属性只有在 synchronous 为 true 时有效。
         */
        option.resizeMode = resizeMode
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { (image, info) in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished {
                completion(image, isDegraded)
            }
        }
        
    }
    
    class func isFetchImageError(_ error: Error?) -> Bool {
        guard let e = error as NSError? else {
            return false
        }
        if e.domain == "CKErrorDomain" || e.domain == "CloudPhotoLibraryErrorDomain" {
            return true
        }
        return false
    }
}
