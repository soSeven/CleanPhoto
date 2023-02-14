//
//  ExportPhotoHelper.swift
//  Clean
//
//  Created by liqi on 2020/10/30.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

class ExportPhotoHelper {
    
    private let sourceDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appendingPathComponent("photoSource")
    private let photoThumbDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appendingPathComponent("photoThumb")
    
    static let shared = ExportPhotoHelper()
    
    init() {
        if !FileManager.default.fileExists(atPath: sourceDirectory) {
            try? FileManager.default.createDirectory(atPath: sourceDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        if !FileManager.default.fileExists(atPath: photoThumbDirectory) {
            try? FileManager.default.createDirectory(atPath: photoThumbDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
//    func exportLivePhoto(for imageAsset: PHAsset, callback: @escaping (_ gifURL: URL?) -> Void) {
//        let options = PHLivePhotoRequestOptions()
//        options.version = .current
//        options.deliveryMode = .highQualityFormat
//        options.isNetworkAccessAllowed = true
//        PHImageManager.default().requestLivePhoto(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (livePhoto, _) in
//
//        }
//        PHImageManager.default().requestImageData(for: imageAsset, options: options) { (data, _, _, _) in
//            if let data = data {
//                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
//                    .appendingUniquePathComponent(pathExtension: "gif")
//                do {
//                    try data.write(to: fileURL)
//                    callback(fileURL)
//                } catch _ {
//                    callback(nil)
//                }
//            } else {
//                callback(nil)
//            }
//        }
//    }
    
    func exportGif(for imageAsset: PHAsset, callback: @escaping (_ gifURL: URL?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .none
        options.isSynchronous = true
        PHImageManager.default().requestImageData(for: imageAsset, options: options) { (data, _, _, _) in
            if let data = data {
                let fileURL = URL(fileURLWithPath: self.sourceDirectory)
                    .appendingUniquePathComponent(pathExtension: "gif")
                do {
                    try data.write(to: fileURL)
                    callback(fileURL)
                } catch _ {
                    callback(nil)
                }
            } else {
                callback(nil)
            }
        }
    }
    
    func exportImage(for imageAsset: PHAsset, callback: @escaping (_ imageURL: URL?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .none
        options.isSynchronous = true
        PHImageManager.default().requestImageData(for: imageAsset, options: options) { (data, _, _, _) in
            if let data = data, let image = UIImage(data: data)?.resetOrientation(), let newData = image.pngData() {
                let fileURL = URL(fileURLWithPath: self.sourceDirectory)
                    .appendingUniquePathComponent(pathExtension: PhotoConfig.imageFileType)
                do {
                    try newData.write(to: fileURL)
                    callback(fileURL)
                } catch _ {
                    callback(nil)
                }
            } else {
                callback(nil)
            }
        }
    }
    
    func exportVideo(for videoAsset: PHAsset, callback: @escaping (_ videoURL: URL?) -> Void) {
        let videoOptions = PHVideoRequestOptions()
        videoOptions.isNetworkAccessAllowed = true
        videoOptions.deliveryMode = .highQualityFormat
        PHImageManager.default().requestExportSession(forVideo: videoAsset, options: videoOptions, exportPreset: AVAssetExportPresetHighestQuality) { (exportSession, info) in
            guard let exportSession = exportSession else {
                callback(nil)
                return
            }
            let fileURL = URL(fileURLWithPath: self.sourceDirectory)
                .appendingUniquePathComponent(pathExtension: PhotoConfig.videoFileType.fileExtension)
            exportSession.outputURL = fileURL
            exportSession.outputFileType = PhotoConfig.videoFileType
            exportSession.shouldOptimizeForNetworkUse = true
            
            try? FileManager.default.removeFileIfNecessary(at: fileURL)
            
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    callback(fileURL)
                default:
                    callback(nil)
                }
            })
        }
    }
    
    func export(for photos: [PhotoModel], progress: ((Float)->())?, completion: (([PhotoModel])->())?) {
        
        var nphotos = [PhotoModel]()
        let totalCount: Float = Float(photos.count)
        var currentCount: Float = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asyncGroup = DispatchGroup()
            for photo in photos {
                asyncGroup.enter()
                switch photo.type {
                case .video:
                    self.exportVideo(for: photo.asset) { url in
                        if let url = url {
                            self.saveThumbImage(for: photo, url: url)
                            let nphoto = PhotoModel(asset: PHAsset())
                            nphoto.isFromLocal = true
                            nphoto.type = .video
                            nphoto.localURL = url
                            nphoto.thumbImage = photo.thumbImage
                            nphotos.append(nphoto)
                            currentCount += 1
                            progress?(currentCount/totalCount)
                        }
                        asyncGroup.leave()
                    }
                case .gif:
                    self.exportGif(for: photo.asset) { url in
                        if let url = url {
                            self.saveThumbImage(for: photo, url: url)
                            let nphoto = PhotoModel(asset: PHAsset())
                            nphoto.isFromLocal = true
                            nphoto.type = .image
                            nphoto.localURL = url
                            nphoto.thumbImage = photo.thumbImage
                            nphotos.append(nphoto)
                            currentCount += 1
                            progress?(currentCount/totalCount)
                        }
                        asyncGroup.leave()
                    }
                default:
                    self.exportImage(for: photo.asset) { url in
                        
                        if let url = url {
                            self.saveThumbImage(for: photo, url: url)
                            let nphoto = PhotoModel(asset: PHAsset())
                            nphoto.isFromLocal = true
                            nphoto.type = .image
                            nphoto.localURL = url
                            nphoto.thumbImage = photo.thumbImage
                            nphotos.append(nphoto)
                            currentCount += 1
                            progress?(currentCount/totalCount)
                        }
                        asyncGroup.leave()
                    }
                }
            }
            asyncGroup.notify(queue: .main) {
                completion?(nphotos)
            }
        }
    }
    
    private func saveThumbImage(for photo: PhotoModel, url: URL) {
        if let thumb = photo.thumbImage, let data = thumb.pngData() {
            let name = url.lastPathComponent.deletingPathExtension
            let fileURL = URL(fileURLWithPath: self.photoThumbDirectory).appendingPathComponent("\(name).png")
            try? data.write(to: fileURL)
        }
    }
    
    func loadLocalPhotos() -> Single<[PhotoModel]>{
        
        return Single<[PhotoModel]>.create { single -> Disposable in
            DispatchQueue.global(qos: .userInitiated).async {
                var paths = (try? FileManager.default.contentsOfDirectory(atPath: self.sourceDirectory)) ?? []
                paths.sort { (path1, path2) -> Bool in
                    let fullPath1 = self.sourceDirectory.appendingPathComponent(path1)
                    let fullPath2 = self.sourceDirectory.appendingPathComponent(path2)
                    let info1 = try? FileManager.default.attributesOfItem(atPath: fullPath1)
                    let info2 = try? FileManager.default.attributesOfItem(atPath: fullPath2)
                    if let info1 = info1, let info2 = info2 {
                        let date1 = info1[.creationDate] as? Date
                        let date2 = info2[.creationDate] as? Date
                        if let date1 = date1, let date2 = date2 {
                            return date1 > date2
                        }
                    }
                    return true
                }
                var photos = [PhotoModel]()
                for path in paths {
                    let photo = PhotoModel(asset: PHAsset())
                    photo.isFromLocal = true
                    let name = path.deletingPathExtension
                    let exten = path.pathExtension
                    switch exten {
                    case "gif":
                        photo.type = .image
                    case PhotoConfig.videoFileType.fileExtension:
                        photo.type = .video
                    case PhotoConfig.imageFileType:
                        photo.type = .image
                    default:
                        photo.type = .image
                    }
                    photo.thumbImage = UIImage(contentsOfFile: self.photoThumbDirectory.appendingPathComponent("\(name).png"))
                    photo.localURL = URL(fileURLWithPath: self.sourceDirectory.appendingPathComponent(path))
                    photos.append(photo)
                }
                DispatchQueue.main.async {
                    single(.success(photos))
                }
            }
            return Disposables.create {}
        }
        
        
    }
    
    func deleteLocalPhoto(_ photoModel: PhotoModel) {
        if let url = photoModel.localURL {
            let name = url.lastPathComponent.deletingPathExtension
            let fileURL = URL(fileURLWithPath: self.photoThumbDirectory).appendingPathComponent("\(name).png")
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func deleteLocalPhotos(for photos: [PhotoModel], progress: ((Float)->())?, completion: (()->())?) {
        
        let totalCount: Float = Float(photos.count)
        var currentCount: Float = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            for photo in photos {
                self.deleteLocalPhoto(photo)
                currentCount += 1
                progress?(currentCount/totalCount)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
        
    }
    
}
