//
//  SimilarDeleteViewController.swift
//  Clean
//
//  Created by liqi on 2020/11/6.
//

import Photos
import RxSwift
import RxCocoa
import RxDataSources
import ADMozaicCollectionViewLayout

protocol SimilarDeleteViewControllerDelegate: AnyObject {
    func similarDeleteDidClickItem(controller: SimilarDeleteViewController, photos: [PhotoModel], index: Int)
}

class SimilarDeleteViewController: ViewController {
    
    weak var delegate: SimilarDeleteViewControllerDelegate?
    
//    var viewModel: SecretPhotoViewModel!
    
    let photosRelay = BehaviorRelay<[PhotoModel]>(value: [])
    let itemsRelay = BehaviorRelay<[[PhotoModel]]>(value: [])
    let deleteRelay = PublishRelay<[PhotoModel]>()
    let showEmpty = BehaviorRelay<Bool>(value: false)
    
    private let deleteBtn = UIButton()
    private var itemDisposeBag = DisposeBag()
    private var selectedPhotos = [PhotoModel]()
    
    var mbStayTimeEvent: String?
    var mbDeleteAll: String?
    
    lazy var collectionView: UICollectionView = {
        let layout = ADMozaikLayout(delegate: self)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 133.uiX + UIDevice.safeAreaBottom, right: 0)
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(cellType: PhotoListCollectionCell.self)
        collectionView.register(supplementaryViewType: SimilarHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)
        
        return collectionView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let eventID = mbStayTimeEvent {
            MobClick.beginEvent(eventID)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let eventID = mbStayTimeEvent {
            MobClick.endEvent(eventID)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Binding
    
    private func setupBinding() {
        
        deleteBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            if self.selectedPhotos.count == 0 {
                return
            }
            if let eventID = self.mbDeleteAll {
                MobClick.beginEvent(eventID)
            }
            let first = self.selectedPhotos[0]
            if first.isFromLocal {
                let delete = DeletePopView()
                delete.imgView.image = first.thumbImage
                delete.rightBtn.rx.tap.subscribe(onNext: {[weak self] in
                    guard let self = self else { return }
                    self.deleteRelay.accept(self.selectedPhotos)
                }).disposed(by: self.rx.disposeBag)
                delete.show()
            } else {
                PhotoManager.shared.delete(photos: self.selectedPhotos) { s in

                }
            }
        }).disposed(by: rx.disposeBag)
        
        deleteRelay.subscribe(onNext: {[weak self] items in
            guard let self = self else { return }
            var photos = self.itemsRelay.value
            photos.removeAll(items)
            self.selectedPhotos.removeAll(items)
            self.itemsRelay.accept(photos)
            self.setupRightItem()
        }).disposed(by: rx.disposeBag)
        
        itemsRelay.bind {[weak self] items in
            guard let self = self else { return }
            self.collectionView.reloadData()
            var photos = [PhotoModel]()
            for i in items {
                photos.append(contentsOf: i)
            }
            self.photosRelay.accept(photos)
        }.disposed(by: rx.disposeBag)
        
        photosRelay.subscribe(onNext: { [weak self] items in
            guard let self = self else { return }
            self.itemDisposeBag = DisposeBag()
            self.showEmpty.accept(items.isEmpty)
            self.selectedPhotos.removeAll()
            for i in items {
                i.selectedType.skip(1).subscribe(onNext: {[weak self] m in
                    guard let self = self else { return }
                    switch m {
                    case .deselected:
                        self.selectedPhotos.removeAll(i)
                    case .selected:
                        if !self.selectedPhotos.contains(i) {
                            self.selectedPhotos.append(i)
                        }
                    }
                    self.setupRightItem()
                }).disposed(by: self.itemDisposeBag)
                if i.selectedType.value == .selected{
                    self.selectedPhotos.append(i)
                }
            }
            self.setupRightItem()
        }).disposed(by: rx.disposeBag)

        collectionView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let self = self else { return }
            let models = self.itemsRelay.value[indexPath.section]
            let photo = models[indexPath.row]
            let index = self.photosRelay.value.firstIndex(of: photo) ?? 0
            self.delegate?.similarDeleteDidClickItem(controller: self, photos: self.photosRelay.value, index: index)
        }).disposed(by: rx.disposeBag)
        
        showEmpty.bind(to: rx.showEmptyView(imageName: "zwkqlzp-icon", title: "暂无可清理照片",inset: .init(top: 30.uiX, left: 0, bottom: 0, right: 0))).disposed(by: rx.disposeBag)
        showEmpty.bind(to: deleteBtn.rx.isHidden).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        view.backgroundColor = .init(hex: "#FFFFFF")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteBtn.cornerRadius = 22.uiX
        deleteBtn.backgroundColor = .init(hex: "#009CFF")
        deleteBtn.setAttributedTitle(.init(string: "删除所选", attributes: [
            .font: UIFont(style: .medium, size: 15.uiX),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ]), for: .normal)
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14.uiX - UIDevice.safeAreaBottom)
            make.right.equalToSuperview().offset(-15.uiX)
            make.left.equalToSuperview().offset(15.uiX)
            make.height.equalTo(44.uiX)
        }
    }
    
    private func setupRightItem() {
        
        let chooseBtn = MusicButton()
        if photosRelay.value.isEmpty {
            navigationItem.rightBarButtonItem = nil
            return
        }
        if selectedPhotos.count == photosRelay.value.count {
            chooseBtn.setAttributedTitle(.init(string: "取消全部", attributes: [
                .font: UIFont(style: .regular, size: 14.uiX),
                .foregroundColor: UIColor(hex: "#009CFF")
            ]), for: .normal)
            chooseBtn.sizeToFit()
            chooseBtn.rx.tap.subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.photosRelay.value.forEach{$0.selectedType.accept(.deselected)}
            }).disposed(by: rx.disposeBag)
        } else {
            chooseBtn.setAttributedTitle(.init(string: "选择全部", attributes: [
                .font: UIFont(style: .regular, size: 14.uiX),
                .foregroundColor: UIColor(hex: "#009CFF")
            ]), for: .normal)
            chooseBtn.sizeToFit()
            chooseBtn.rx.tap.subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.photosRelay.value.forEach{$0.selectedType.accept(.selected)}
            }).disposed(by: rx.disposeBag)
        }

        navigationItem.rightBarButtonItem = .init(customView: chooseBtn)
    }
    
}

extension SimilarDeleteViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return itemsRelay.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = itemsRelay.value[section]
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = itemsRelay.value[indexPath.section]
        let item = items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PhotoListCollectionCell.self)
        cell.photoModel = item
        if indexPath.row == 0 {
            cell.bestMarkImgView.isHidden = false
        } else {
            cell.bestMarkImgView.isHidden = true
        }
        if item.asset.mediaType != .image {
            cell.timeLbl.isHidden = false
        } else {
            cell.timeLbl.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath, viewType: SimilarHeaderView.self)
        let items = itemsRelay.value[indexPath.section]
        header.titleLbl.text = "\(items.count)张照片"
        return header
    }
    
    
}

extension SimilarDeleteViewController: ADMozaikLayoutDelegate {
    
    func collectonView(_ collectionView: UICollectionView, mozaik layoyt: ADMozaikLayout, geometryInfoFor section: ADMozaikLayoutSection) -> ADMozaikLayoutSectionGeometryInfo {
        let rowHeight: CGFloat = 84.uiX
        let columns = [ADMozaikLayoutColumn(width: 84.uiX), ADMozaikLayoutColumn(width: 84.uiX), ADMozaikLayoutColumn(width: 84.uiX), ADMozaikLayoutColumn(width: 84.uiX)]
        let geometryInfo = ADMozaikLayoutSectionGeometryInfo(rowHeight: rowHeight,
                                                             columns: columns,
                                                             minimumInteritemSpacing: 3.uiX,
                                                             minimumLineSpacing: 3.uiX,
                                                             sectionInset: UIEdgeInsets(top: 0, left: 15.uiX, bottom: 0, right: 15.uiX),
                                                             headerHeight: 37.uiX, footerHeight: 0)
        return geometryInfo
    }
    
    func collectionView(_ collectionView: UICollectionView, mozaik layout: ADMozaikLayout, mozaikSizeForItemAt indexPath: IndexPath) -> ADMozaikLayoutSize {
        if indexPath.item == 0 {
            return ADMozaikLayoutSize(numberOfColumns: 2, numberOfRows: 2)
        }
        else {
            return ADMozaikLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        }
    }
    
}
