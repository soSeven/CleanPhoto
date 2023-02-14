//
//  AlbumsManager.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

//import Foundation
//import Photos
//import UIKit
//
//class AlbumsManager {
//    
//    private var cachedAlbums: [Album]?
//    
//    func fetchAlbums() -> [Album] {
//        if let cachedAlbums = cachedAlbums {
//            return cachedAlbums
//        }
//        
//        var albums = [Album]()
//        let options = PHFetchOptions()
//        
//        let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
//                                                                        subtype: .any,
//                                                                        options: options)
//        let albumsResult = PHAssetCollection.fetchAssetCollections(with: .album,
//                                                                   subtype: .any,
//                                                                   options: options)
//        let deletesResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
//                                                                    subtype: PHAssetCollectionSubtype(rawValue: 1000000201)!,
//                                                                   options: options)
//
//        for result in [smartAlbumsResult, albumsResult, deletesResult] {
//            result.enumerateObjects({ assetCollection, _, _ in
//                var album = Album()
//                
//                album.title = assetCollection.localizedTitle ?? ""
//                if album.title == "Recents" {
//                    print(assetCollection.assetCollectionSubtype.rawValue)
//                }
//                album.numberOfItems = self.mediaCountFor(collection: assetCollection)
//                if album.numberOfItems > 0 {
//                    let r = PHAsset.fetchKeyAssets(in: assetCollection, options: nil)
//                    if let first = r?.firstObject {
//                        let deviceScale = UIScreen.main.scale
//                        let targetSize = CGSize(width: 78*deviceScale, height: 78*deviceScale)
//                        let options = PHImageRequestOptions()
//                        options.isSynchronous = true
//                        options.deliveryMode = .opportunistic
//                        PHImageManager.default().requestImage(for: first,
//                                                              targetSize: targetSize,
//                                                              contentMode: .aspectFill,
//                                                              options: options,
//                                                              resultHandler: { image, _ in
//                                                                album.thumbnail = image
//                        })
//                    }
//                    album.collection = assetCollection
//                    
//                    if PhotoConfig.mediaType == .photo {
//                        if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
//                            || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
//                            albums.append(album)
//                        }
//                    } else {
//                        albums.append(album)
//                    }
//                }
//            })
//        }
//        cachedAlbums = albums
//        return albums
//    }
//    
//    func mediaCountFor(collection: PHAssetCollection) -> Int {
//        let options = PHFetchOptions()
//        options.predicate = PhotoConfig.mediaType.predicate()
//        let result = PHAsset.fetchAssets(in: collection, options: options)
//        return result.count
//    }
//    
//}
//
//enum libraryMediaType {
//    case photo
//    case video
//    case photoAndVideo
//}
//
//extension libraryMediaType {
//    func predicate() -> NSPredicate {
//        switch self {
//        case .photo:
//            return NSPredicate(format: "mediaType = %d",
//                               PHAssetMediaType.image.rawValue)
//        case .video:
//            return NSPredicate(format: "mediaType = %d",
//                               PHAssetMediaType.video.rawValue)
//        case .photoAndVideo:
//            return NSPredicate(format: "mediaType = %d || mediaType = %d",
//                               PHAssetMediaType.image.rawValue,
//                               PHAssetMediaType.video.rawValue)
//        }
//    }
//}
