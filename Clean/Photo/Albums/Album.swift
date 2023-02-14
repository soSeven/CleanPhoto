//
//  Album.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import UIKit
import Photos
import RxCocoa
import RxSwift

class Album {
    
    enum AlbumType {
        /// 屏幕截图
        case snapPhoto
        /// 重复的照片
        case repeatPhoto
        /// 相似的照片
        case similarPhoto
        /// 类似动态照片
        case livePhoto
        /// 相似连拍照片
        case similarMostPhoto
        /// 相似视频
        case similarVideo
        /// 模糊的照片
        case badPhoto
        /// 有地址的照片
        case addressPhoto
        
        case none
        
        var title: String {
            switch self {
            case .snapPhoto:
                return "屏幕截图"
            case .repeatPhoto:
                return "重复的照片"
            case .similarPhoto:
                return "相似的照片"
            case .livePhoto:
                return "类似动态照片"
            case .similarMostPhoto:
                return "相似连拍照片"
            case .similarVideo:
                return "相似视频"
            case .badPhoto:
                return "模糊的照片"
            case .addressPhoto:
                return "有地址的照片"
            default:
                return ""
            }
        }
    }
    
    var type: AlbumType
    var thumbnail: UIImage?
    var numberOfItems: Int = 0
    var collection: PHAssetCollection?
    let photos = BehaviorRelay<[PhotoModel]>(value: [])
    let photosAlbum = BehaviorRelay<[[PhotoModel]]>(value: [])
    let rangePhotos = BehaviorRelay<[PhotoModel]>(value: [])
    let rangePhotosAlbum = BehaviorRelay<[[PhotoModel]]>(value: [])
    let timeRange = BehaviorRelay<(Date?, Date?)>(value: (nil, nil))
    let loading = BehaviorRelay<Bool>(value: true)
    let selected = BehaviorRelay<Bool>(value: true)
    
    private var disposeBag = DisposeBag()
    
    init(type: AlbumType) {
        self.type = type
        
        let photosRelay = Observable.combineLatest(photos.asObservable(), timeRange.asObservable())
        photosRelay.subscribe(onNext: {[weak self] (ps, date) in
            guard let self = self else { return }
            if let date1 = date.0, let date2 = date.1 {
                let newPhotos = ps.filter { p -> Bool in
                    if let createDate = p.asset.creationDate {
                        return createDate.year >= date1.year
                            && createDate.month >= date1.month
                            && createDate.year <= date2.year
                            && createDate.month <= date2.month
                    }
                    return true
                }
                self.rangePhotos.accept(newPhotos)
            } else {
                self.rangePhotos.accept(ps)
            }
        }).disposed(by: disposeBag)
        
        let photosAlbumRelay = Observable.combineLatest(photosAlbum.asObservable(), timeRange.asObservable())
        photosAlbumRelay.subscribe(onNext: {[weak self] (ps, date) in
            guard let self = self else { return }
            if let date1 = date.0, let date2 = date.1 {
                var newAlbum = [[PhotoModel]]()
                for photos in ps {
                    let newPhotos = photos.filter { p -> Bool in
                        if let createDate = p.asset.creationDate {
                            return createDate.year >= date1.year
                                && createDate.month >= date1.month
                                && createDate.year <= date2.year
                                && createDate.month <= date2.month
                        }
                        return true
                    }
                    if newPhotos.count > 1 {
                        newAlbum.append(newPhotos)
                    }
                }
                self.rangePhotosAlbum.accept(newAlbum)
            } else {
                self.rangePhotosAlbum.accept(ps)
            }
        }).disposed(by: disposeBag)
        
    }
    
}
