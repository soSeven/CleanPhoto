//
//  PhotoManager.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import RxCocoa
import RxSwift
import Photos

class PhotoManager: NSObject {
    
    enum ProgressType {
        case check
        case start(Int, Int)
        case progress(Int, Int)
        case end(Int, Int, Int, Int)
    }
    
    static let shared = PhotoManager()
    
    let snapPhotoAlbum = Album(type: .snapPhoto)
    let similarPhotoAlbum = Album(type: .similarPhoto)
    let livePhotoAlbum = Album(type: .livePhoto)
    let similarMostPhotoAlbum = Album(type: .similarMostPhoto)
    let similarVideoAlbum = Album(type: .similarVideo)
    let badPhotoAlbum = Album(type: .badPhoto)
    let addressPhotoAlbum = Album(type: .addressPhoto)
    
    let progressRelay = BehaviorRelay<ProgressType>(value: .check)
    let albumsRelay = BehaviorRelay<[Album]>(value: [])
    let photosRelay = BehaviorRelay<[PhotoModel]>(value: [])
    
    let minAndMaxCreateDate = BehaviorRelay<(Date?, Date?)>(value: (nil, nil))
    
    var progressDisposeBag = DisposeBag()
    
    private var loading = false
    var needLoading = true
    
    override init() {
        
        super.init()
        albumsRelay.accept([
                            snapPhotoAlbum,
                            similarPhotoAlbum,
                            livePhotoAlbum,
                            similarMostPhotoAlbum,
                            similarVideoAlbum,
                            badPhotoAlbum,
                            addressPhotoAlbum])
    }
    
    func checkPermissionToAccessPhotoLibrary(block: @escaping (Bool) -> Void) {
        // Only intilialize picker if photo permission is Allowed by user.
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            block(true)
        #if compiler(>=5.3)
        case .limited:
            block(true)
        #endif
        case .restricted, .denied:
            let popup = MessageAlertView()
            popup.titleLbl.text = "访问相册"
            popup.contentLbl.text = "使用这些功能需要访问您的相册，请允许访问"
            let att: [NSAttributedString.Key:Any] = [
                .font: UIFont(style: .regular, size: 15.uiX),
                .foregroundColor: UIColor(hex: "#FFFFFF"),
            ]
            popup.rightBtn.setAttributedTitle(.init(string: "去设置", attributes: att), for: .normal)
            popup.leftBtn.rx.tap.subscribe(onNext: {
                block(false)
            }).disposed(by: popup.rx.disposeBag)
            popup.rightBtn.rx.tap.subscribe(onNext: {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }).disposed(by: popup.rx.disposeBag)
            popup.show()
        case .notDetermined:
            // Show permission popup and get new status
            PHPhotoLibrary.requestAuthorization { s in
                DispatchQueue.main.async {
                    block(s == .authorized)
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
    func fetchAlbums() {
        
        if loading {
            return
        }
        loading = true
        needLoading = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self = self else { return }
            
            self.progressRelay.accept(.start(0, 0))
            
            var needCleanCount = 0
            var needCleanTotalBytes = 0
            
            let options = PHFetchOptions()
            let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                            subtype: .any,
                                                                            options: options)
            let fetchOptions = self.buildPHFetchOptions()
            
            var snapPhotos = [PhotoModel]()
            var livePhotos = [PhotoModel]()
            var addressPhotos = [PhotoModel]()
            var burstPhotos = [PhotoModel]()
            var userLibraryPhotos = [PhotoModel]()
            smartAlbumsResult.enumerateObjects({ assetCollection, _, _ in
                
                let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                var photos = [PhotoModel]()
                fetchResult.enumerateObjects { (p, _, _) in
                    let photoModel = PhotoModel(asset: p)
                    photos.append(photoModel)
                }
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = true
                switch assetCollection.assetCollectionSubtype {
                case .smartAlbumScreenshots:
                    snapPhotos = photos
                    for photo in snapPhotos {
                        photo.selectedType.accept(.selected)
                        _ = autoreleasepool {
                            PHImageManager.default().requestImageData(for: photo.asset, options: options) { (data, _, _, _) in
                                if let data = data {
                                    photo.dataLength = data.count
//                                    print(photo.dataLength)
                                }
                            }
                        }
                    }
                case .smartAlbumLivePhotos:
                    livePhotos = photos
                
                case .smartAlbumUserLibrary:
                    userLibraryPhotos = photos
                    addressPhotos = photos.filter{$0.asset.location != nil}
                case .smartAlbumBursts:
                    burstPhotos = photos
                default:
                    break
                }
            })
            
            needCleanCount += snapPhotos.count
            needCleanTotalBytes += snapPhotos.reduce(0) { $0 + $1.dataLength }
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                
                var firstCreateDate: Date?
                if let first = userLibraryPhotos.first {
                    firstCreateDate = first.asset.creationDate
                }
                var lastCreateDate: Date?
                if let last = userLibraryPhotos.last {
                    lastCreateDate = last.asset.creationDate
                }
                self.minAndMaxCreateDate.accept((lastCreateDate, firstCreateDate))
                
                self.snapPhotoAlbum.loading.accept(false)
                self.snapPhotoAlbum.photos.accept(snapPhotos)
                
                self.livePhotoAlbum.loading.accept(false)
                self.livePhotoAlbum.photos.accept(livePhotos)
                
                self.addressPhotoAlbum.loading.accept(false)
                self.addressPhotoAlbum.photos.accept(addressPhotos)
            }
            
            var badPhotos = [PhotoModel]()
            var needCheckPhotos = [PhotoModel]()
            var needCheckVideos = [PhotoModel]()
            var needCheckLives = [PhotoModel]()
            var needCheckBursts = [PhotoModel]()
            var finishedCount = 0
            let totalCount = userLibraryPhotos.count
            var hashMap = [String:UInt64]()
            var imageMap = [String:UIImage]()
            
            // 检测模糊图片
            let sem = DispatchSemaphore(value: 0)
            for photo in userLibraryPhotos {
                
                if photo.asset.mediaSubtypes == .photoScreenshot {
                    finishedCount += 1
                    self.progressRelay.accept(.progress(finishedCount, totalCount))
                    continue
                }
                
                autoreleasepool {
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .highQualityFormat
                    options.isSynchronous = true
                    
                    if photo.asset.mediaType == .video {
                        let videoOptions = PHVideoRequestOptions()
                        videoOptions.version = .original
                        PHImageManager.default().requestAVAsset(forVideo: photo.asset, options: videoOptions) { (asset, _, _) in
                            if let avAsset = asset as? AVURLAsset {
                                let size = try? avAsset.url.resourceValues(forKeys: [.fileSizeKey])
                                photo.dataLength = size?.fileSize ?? 0
                            }
                            sem.signal()
                        }
                        sem.wait()
                    } else {
                        PHImageManager.default().requestImageData(for: photo.asset, options: options) { (data, _, _, _) in
                            if let data = data {
                                photo.dataLength = data.count
//                                print(photo.dataLength)
                            }
                        }
                    }
                    
                    PHImageManager.default().requestImage(for: photo.asset, targetSize: .init(width: 200, height: 200), contentMode: .default, options: options) { (image, _) in
                        guard let image = image else {
                            finishedCount += 1
                            self.progressRelay.accept(.progress(finishedCount, totalCount))
                            return
                        }
                        if photo.asset.mediaType == .video {
                            needCheckVideos.append(photo)
                            imageMap[photo.asset.localIdentifier] = image
                        } else {
                            let isBurry = OpenCVWrapper.checkBurry(image)
                            if isBurry {
                                badPhotos.append(photo)
                                finishedCount += 1
                                self.progressRelay.accept(.progress(finishedCount, totalCount))
                            } else {
                                let isLive = livePhotos.contains { m -> Bool in
                                    autoreleasepool {
                                        return photo.asset.localIdentifier == m.asset.localIdentifier
                                    }
                                }
                                if isLive {
                                    needCheckLives.append(photo)
                                } else {
                                    let isBurst = burstPhotos.contains { m -> Bool in
                                        autoreleasepool {
                                            return photo.asset.localIdentifier == m.asset.localIdentifier
                                        }
                                    }
                                    if isBurst {
                                        needCheckBursts.append(photo)
                                    } else {
                                        needCheckPhotos.append(photo)
                                    }
                                }
                                imageMap[photo.asset.localIdentifier] = image
                            }
                        }
                    }
                }
            }
            
            needCleanCount += badPhotos.count
            needCleanTotalBytes += badPhotos.reduce(0) { $0 + $1.dataLength }
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.badPhotoAlbum.loading.accept(false)
                self.badPhotoAlbum.photos.accept(badPhotos)
            }
            
            var similarBurstIndexSet = [Set<Int>]()
            
            // 检测连拍图片
            for i in 0..<needCheckBursts.count {
                
                autoreleasepool {
                    
                    let photo = needCheckBursts[i]
                    if hashMap[photo.asset.localIdentifier] == nil {
                        hashMap[photo.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[photo.asset.localIdentifier]!)
                    }
                    
                    var set = Set<Int>()
                    set.insert(i)
                    
                    for j in i+1..<needCheckBursts.count {
                        autoreleasepool {
                            let checkPhoto = needCheckBursts[j]
                            if hashMap[checkPhoto.asset.localIdentifier] == nil {
                                hashMap[checkPhoto.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[checkPhoto.asset.localIdentifier]!)
                            }
                            //AHash 第一次检测
                            let hashA = hashMap[photo.asset.localIdentifier]!
                            let hashB = hashMap[checkPhoto.asset.localIdentifier]!
                            let isSimilar = self.checkHashSimilar(hashA, hashB)
                            //直方图算法 第二次检测
                            if isSimilar {
                                let imageA = imageMap[photo.asset.localIdentifier]!
                                let imageB = imageMap[checkPhoto.asset.localIdentifier]!
                                let isSimilar2 = OpenCVWrapper.checkSimilar2(imageA, imageB: imageB)
                                if isSimilar2 {
                                    set.insert(j)
                                }
                            }
                        }
                    }
                    if set.count > 1 {
                        similarBurstIndexSet.append(set)
                    }
                    finishedCount += 1
                    self.progressRelay.accept(.progress(finishedCount, totalCount))
                }
            }

            var similarBurstsAlbum = [[PhotoModel]]()
            self.mapReduce(list: &similarBurstIndexSet)
            for idxs in similarBurstIndexSet {
                var photos = idxs.map { needCheckBursts[$0] }.sorted(by: self.sortImage(p1:p2:))
                similarBurstsAlbum.append(photos)
                photos.removeFirst()
                photos.forEach{$0.selectedType.accept(.selected)}
                needCleanCount += photos.count
                needCleanTotalBytes += photos.reduce(0) { $0 + $1.dataLength }
            }

            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.similarMostPhotoAlbum.loading.accept(false)
                self.similarMostPhotoAlbum.photosAlbum.accept(similarBurstsAlbum)
            }

            var similarLiveIndexSet = [Set<Int>]()
            
            // 检测相似动态图片
            for i in 0..<needCheckLives.count {
                autoreleasepool {
                    
                    let photo = needCheckLives[i]
                    if hashMap[photo.asset.localIdentifier] == nil {
                        hashMap[photo.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[photo.asset.localIdentifier]!)
                    }
                    
                    var set = Set<Int>()
                    set.insert(i)
                    
                    for j in i+1..<needCheckLives.count {
                        autoreleasepool {
                            let checkPhoto = needCheckLives[j]
                            if hashMap[checkPhoto.asset.localIdentifier] == nil {
                                hashMap[checkPhoto.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[checkPhoto.asset.localIdentifier]!)
                            }
                            //AHash 第一次检测
                            let hashA = hashMap[photo.asset.localIdentifier]!
                            let hashB = hashMap[checkPhoto.asset.localIdentifier]!
                            let isSimilar = self.checkHashSimilar(hashA, hashB)
                            
                            //直方图算法 第二次检测
                            if isSimilar {
                                let imageA = imageMap[photo.asset.localIdentifier]!
                                let imageB = imageMap[checkPhoto.asset.localIdentifier]!
                                let isSimilar2 = OpenCVWrapper.checkSimilar2(imageA, imageB: imageB)
                                if isSimilar2 {
                                    set.insert(j)
                                }
                            }
                        }
                        
                    }
                    if set.count > 1 {
                        similarLiveIndexSet.append(set)
                    }
                    finishedCount += 1
                    self.progressRelay.accept(.progress(finishedCount, totalCount))
                }
            }
            
            var similarLiveAlbum = [[PhotoModel]]()
            self.mapReduce(list: &similarLiveIndexSet)
            for idxs in similarLiveIndexSet {
                var photos = idxs.map { needCheckLives[$0] }.sorted(by: self.sortImage(p1:p2:))
                similarLiveAlbum.append(photos)
                photos.removeFirst()
                photos.forEach{$0.selectedType.accept(.selected)}
                needCleanCount += photos.count
                needCleanTotalBytes += photos.reduce(0) { $0 + $1.dataLength }
            }
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.livePhotoAlbum.loading.accept(false)
                self.livePhotoAlbum.photosAlbum.accept(similarLiveAlbum)
            }

            var similarVideoIndexSet = [Set<Int>]()

            // 检测相似视频
            for i in 0..<needCheckVideos.count {
                autoreleasepool {
                    
                    let photo = needCheckVideos[i]
                    if hashMap[photo.asset.localIdentifier] == nil {
                        hashMap[photo.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[photo.asset.localIdentifier]!)
                    }
                    
                    var set = Set<Int>()
                    set.insert(i)
                    
                    for j in i+1..<needCheckVideos.count {
                        
                        autoreleasepool {
                            let checkPhoto = needCheckVideos[j]
                            if hashMap[checkPhoto.asset.localIdentifier] == nil {
                                hashMap[checkPhoto.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[checkPhoto.asset.localIdentifier]!)
                            }
                            //AHash 第一次检测
                            let hashA = hashMap[photo.asset.localIdentifier]!
                            let hashB = hashMap[checkPhoto.asset.localIdentifier]!
                            let isSimilar = self.checkHashSimilar(hashA, hashB)
                            
                            //直方图算法 第二次检测
                            if isSimilar {
                                let imageA = imageMap[photo.asset.localIdentifier]!
                                let imageB = imageMap[checkPhoto.asset.localIdentifier]!
                                let isSimilar2 = OpenCVWrapper.checkSimilar2(imageA, imageB: imageB)
                                if isSimilar2 {
                                    set.insert(j)
                                }
                            }
                        }
                        
                    }
                    if set.count > 1 {
                        similarVideoIndexSet.append(set)
                    }
                    finishedCount += 1
                    self.progressRelay.accept(.progress(finishedCount, totalCount))
                }
            }

            var similarVideoAlbum = [[PhotoModel]]()
            self.mapReduce(list: &similarVideoIndexSet)
            for idxs in similarVideoIndexSet {
                var photos = idxs.map { needCheckVideos[$0] }.sorted(by: self.sortVideo(p1:p2:))
                similarVideoAlbum.append(photos)
                photos.removeFirst()
                photos.forEach{$0.selectedType.accept(.selected)}
                needCleanCount += photos.count
                needCleanTotalBytes += photos.reduce(0) { $0 + $1.dataLength }
            }

            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.similarVideoAlbum.loading.accept(false)
                self.similarVideoAlbum.photosAlbum.accept(similarVideoAlbum)
            }
            
            var similarPhotoIndexSet = [Set<Int>]()
            // 检测相似图片
            for i in 0..<needCheckPhotos.count {
                autoreleasepool {
                    
                    let photo = needCheckPhotos[i]
                    if hashMap[photo.asset.localIdentifier] == nil {
                        hashMap[photo.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[photo.asset.localIdentifier]!)
                    }
    
                    var set = Set<Int>()
                    set.insert(i)
                    
                    for j in i+1..<needCheckPhotos.count {
                        autoreleasepool {
                            let checkPhoto = needCheckPhotos[j]
                            if hashMap[checkPhoto.asset.localIdentifier] == nil {
                                hashMap[checkPhoto.asset.localIdentifier] = OpenCVWrapper.calcHash(imageMap[checkPhoto.asset.localIdentifier]!)
                            }
                            //AHash 第一次检测
                            let hashA = hashMap[photo.asset.localIdentifier]!
                            let hashB = hashMap[checkPhoto.asset.localIdentifier]!
                            let isSimilar = self.checkHashSimilar(hashA, hashB)
                            
                            // 直方图算法 第二次检测
                            if isSimilar {
                                let imageA = imageMap[photo.asset.localIdentifier]!
                                let imageB = imageMap[checkPhoto.asset.localIdentifier]!
                                let isSimilar2 = OpenCVWrapper.checkSimilar2(imageA, imageB: imageB)
                                if isSimilar2 {
                                    set.insert(j)
                                }
                            }
                        }
                    }
                    if set.count > 1 {
                        similarPhotoIndexSet.append(set)
                    }
                    finishedCount += 1
                    self.progressRelay.accept(.progress(finishedCount, totalCount))
                }
            }
            
            var similarAlbum = [[PhotoModel]]()
            self.mapReduce(list: &similarPhotoIndexSet)
            for idxs in similarPhotoIndexSet {
                var photos = idxs.map { needCheckPhotos[$0] }.sorted(by: self.sortImage(p1:p2:))
                similarAlbum.append(photos)
                photos.removeFirst()
                photos.forEach{$0.selectedType.accept(.selected)}
                needCleanCount += photos.count
                needCleanTotalBytes += photos.reduce(0) { $0 + $1.dataLength }
            }
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.similarPhotoAlbum.loading.accept(false)
                self.similarPhotoAlbum.photosAlbum.accept(similarAlbum)
                self.loading = false
            }
            
            self.progressRelay.accept(.end(finishedCount, totalCount, needCleanCount, needCleanTotalBytes))
        }
    }
    
    func fetchUserLibrary() -> Single<[PhotoModel]> {
        
        return Single<[PhotoModel]>.create {single -> Disposable in
            DispatchQueue.global(qos: .userInitiated).async {

                let options = PHFetchOptions()
                let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                                subtype: .smartAlbumUserLibrary,
                                                                                options: options)
                var photos = [PhotoModel]()
                smartAlbumsResult.enumerateObjects({ assetCollection, idx, stop in
                    if assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                        let options = self.buildPHFetchOptions()
                        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                        fetchResult.enumerateObjects { (p, _, _) in
                            let photoModel = PhotoModel(asset: p)
                            photoModel.selectedType.accept(.deselected)
                            photos.append(photoModel)
                        }
                        stop.pointee = true
                    }
                })
                
                DispatchQueue.main.async {
                    single(.success(photos))
                }
            }
            return Disposables.create{}
        }
        
        
    }
    
    func buildPHFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        options.predicate = PhotoConfig.mediaType.predicate()
        return options
    }
    
    var isDeleteing = false
    func delete(photos: [PhotoModel], success: @escaping ([PhotoModel])->()) {
        if photos.isEmpty {
            return
        }
        let deletePhotos = photos.filter({ p -> Bool in
            p.asset.canPerform(.delete)
        })
        if deletePhotos.isEmpty {
            return
        }
        let maskPopView = MaskEffectPopView()
        maskPopView.show()
        isDeleteing = true
        PHPhotoLibrary.shared().performChanges {
            let assets = deletePhotos.map{$0.asset}
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        } completionHandler: { (finished, error) in
            DispatchQueue.main.async {
                if finished, error == nil {
                    success(deletePhotos)

                    var currentSnap = self.snapPhotoAlbum.photos.value
                    currentSnap.removeAll { m -> Bool in
                        return deletePhotos.contains { nM -> Bool in
                            nM.asset.localIdentifier == m.asset.localIdentifier
                        }
                    }
                    self.snapPhotoAlbum.photos.accept(currentSnap)
                    
                    let currentSimilarPhotoAlbum = self.similarPhotoAlbum.photosAlbum.value
                    var newSimilarPhotoAlbum = [[PhotoModel]]()
                    for album in currentSimilarPhotoAlbum {
                        var nAlbum = album
                        nAlbum.removeAll { m -> Bool in
                            return deletePhotos.contains { nM -> Bool in
                                nM.asset.localIdentifier == m.asset.localIdentifier
                            }
                        }
                        if nAlbum.count > 1 {
                            newSimilarPhotoAlbum.append(nAlbum)
                        }
                    }
                    self.similarPhotoAlbum.photosAlbum.accept(newSimilarPhotoAlbum)
                    
                    var currentLive = self.livePhotoAlbum.photos.value
                    currentLive.removeAll { m -> Bool in
                        return deletePhotos.contains { nM -> Bool in
                            nM.asset.localIdentifier == m.asset.localIdentifier
                        }
                    }
                    self.livePhotoAlbum.photos.accept(currentLive)
                    
                    let currentSimilarMostAlbum = self.similarMostPhotoAlbum.photosAlbum.value
                    var newSimilarMostAlbum = [[PhotoModel]]()
                    for album in currentSimilarMostAlbum {
                        var nAlbum = album
                        nAlbum.removeAll { m -> Bool in
                            return deletePhotos.contains { nM -> Bool in
                                nM.asset.localIdentifier == m.asset.localIdentifier
                            }
                        }
                        if nAlbum.count > 1 {
                            newSimilarMostAlbum.append(nAlbum)
                        }
                    }
                    self.similarMostPhotoAlbum.photosAlbum.accept(newSimilarMostAlbum)
                    
                    let currentSimilarVideoAlbum = self.similarVideoAlbum.photosAlbum.value
                    var newSimilarVideoAlbum = [[PhotoModel]]()
                    for album in currentSimilarVideoAlbum {
                        var nAlbum = album
                        nAlbum.removeAll { m -> Bool in
                            return deletePhotos.contains { nM -> Bool in
                                nM.asset.localIdentifier == m.asset.localIdentifier
                            }
                        }
                        if nAlbum.count > 1 {
                            newSimilarVideoAlbum.append(nAlbum)
                        }
                    }
                    self.similarVideoAlbum.photosAlbum.accept(newSimilarVideoAlbum)
                    
                    var currentBad = self.badPhotoAlbum.photos.value
                    currentBad.removeAll { m -> Bool in
                        return deletePhotos.contains { nM -> Bool in
                            nM.asset.localIdentifier == m.asset.localIdentifier
                        }
                    }
                    self.badPhotoAlbum.photos.accept(currentBad)
                    
                    var currentAdress = self.addressPhotoAlbum.photos.value
                    currentAdress.removeAll { m -> Bool in
                        return deletePhotos.contains { nM -> Bool in
                            nM.asset.localIdentifier == m.asset.localIdentifier
                        }
                    }
                    self.addressPhotoAlbum.photos.accept(currentAdress)

                } else {
                    
                }
                maskPopView.hide()
                self.isDeleteing = false
            }
        }
    }
    
    func checkHashSimilar(_ x: UInt64, _ y: UInt64) -> Bool {
        var num : UInt64 = x ^ y
        var sum : Int = 0
        while (num > 0) {
            sum += (num & 1) == 1 ? 1 : 0
            num = num >> 1
        }
        return sum < 8
    }
    
    private func sortImage(p1: PhotoModel, p2: PhotoModel) -> Bool {
        return (p1.asset.pixelWidth * p1.asset.pixelHeight) > (p2.asset.pixelWidth * p2.asset.pixelHeight)
    }
    
    private func sortVideo(p1: PhotoModel, p2: PhotoModel) -> Bool {
        return p1.duration > p2.duration
    }
    
    /**
    * 合并有交集的集合
    *
    * 方法：hash表+并查集
    * 建立一个hash表，key为集合元素，value为元素出现的集合，
    * 同时建立一个子hash，作用是建立当前元素所在集合与元素第一次出现的集合之间的关系，key为元素当前的集合，value为元素第一次出现的集合。
    * 这样通过遍历，就建立起了一个并查集结构，将所有有交集的元素指向同一个集合中。
    *
    * 然后建立一个列表，列表下标为集合编号，下标对应元素为并查集的根集合。通过子hash，汇总各集合对应的根集合，并将其更新到列表中。然后根据列表记录汇总合并对应集合即可。
    * 注意在子hash中，元素第一次出现的集合可能并非根集合，此时要通过继续查找子hash找到根集合。
    *
    */
    func mapReduce(list: inout [Set<Int>]){
        let len = list.count
        var root = Array(repeating: -1, count: len)
        var dict: [Int: [Int]] = [:]
        //扫描集合中个元素，记录每个元素所在集合的下标，提取重叠关系。
        for i in 0..<len {
            for j in list[i] {
                if (!dict.keys.contains(j)) {
                    dict[j] = [i]
                } else {
                    dict[j]!.append(i)
                }
            }
        }
        
        //遍历重叠关系，合并集合
        for v in dict.values {
            if v.count == 1 {
                if root[v[0]] == -1 { //只有一个孤立点的集合，root节点指向自身
                    root[v[0]] = v[0]
                }
            } else {
                //路径压缩，合并到最前面的root
                var minv = v.min()!
                for k in v {
                    if root[k] != -1 && minv > root[k] {
                        minv = root[k]
                    }
                }
                var set = [Int]()
                for k in v {
                    if root[k] != minv {
                        if root[k] != -1 && !set.contains(root[k]) {
                            set.append(root[k])
                        }
                        root[k] = minv
                    }
                }
                
                //合并所有相关的子集
                if set.count > 0 {
                    for k in 0..<len {
                        if set.contains(root[k]) {
                            root[k] = minv
                        }
                    }
                }
            }
        }
        
        for i in 0..<len {
            if (root[i] != i) {
                list[root[i]] = list[root[i]].union(list[i])
            }
        }
        
        var res = [Set<Int>]()
        for i in Set(root) {
            res.append(list[i])
        }
        
        list.removeAll()
        list = res
    }
}
