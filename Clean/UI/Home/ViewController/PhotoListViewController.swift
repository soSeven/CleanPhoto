//
//  PhotoListViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import Photos
import RxSwift
import RxCocoa

protocol PhotoListViewControllerDelegate: AnyObject {
    func photoListDidClickItem(controller: PhotoListViewController)
}

class PhotoListViewController: ViewController {
    
    weak var delegate: PhotoListViewControllerDelegate?
    
    private var fetchResult: PHFetchResult<PHAsset>!
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let m = 3.uiX
        let w = (UIDevice.screenWidth - 3*m)/4.0
        layout.itemSize = .init(width: w, height: w)
        layout.minimumLineSpacing = m
        layout.minimumInteritemSpacing = m
//        layout.sectionInset = .init(top: 0, left: 9.5.uiX, bottom: 0, right: 9.5.uiX)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(cellType: PhotoListCollectionCell.self)
        
        return collectionView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    func setAlbum(_ album: Album) {
        title = album.type.title
//        let options = buildPHFetchOptions()
//        if let collection = album.collection {
//            fetchResult = PHAsset.fetchAssets(in: collection, options: options)
//        } else {
//            fetchResult = PHAsset.fetchAssets(with: options)
//        }
        collectionView.reloadData()
    }
    
//    func buildPHFetchOptions() -> PHFetchOptions {
//        let options = PHFetchOptions()
//        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        options.predicate = PhotoConfig.mediaType.predicate()
//        return options
//    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
//        let results = mediaManager.fetchResult!
//        Observable.just(results).bind(to: collectionView.rx.items(cellIdentifier: PhotoListCollectionCell.reuseIdentifier, cellType: PhotoListCollectionCell.self)) { [weak self] (row, element, cell) in
//            guard let self = self else { return }
//
//        }.disposed(by: rx.disposeBag)
//
//        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] index in
//            guard let self = self else { return }
////            self.collectionView.reloadData()
//        }).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        view.backgroundColor = .init(hex: "#FFFFFF")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
}

extension PhotoListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult[indexPath.item]
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PhotoListCollectionCell.self)
        cell.representedAssetIdentifier = asset.localIdentifier
        PHCacheManager.cache.requestImage(for: asset,
                                          targetSize: PHCacheManager.getTargetCellSize(),
                                          contentMode: .aspectFill,
                                          options: nil) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.imgView.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
}

extension PhotoListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let asset = mediaManager.fetchResult[indexPath.item]
        delegate?.photoListDidClickItem(controller: self)
    }
    
}

