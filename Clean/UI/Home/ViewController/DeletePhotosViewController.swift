//
//  DeletePhotosViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/31.
//

import Photos
import RxSwift
import RxCocoa
import MBProgressHUD

protocol DeletePhotosViewControllerDelegate: AnyObject {
    func secretPhotoDidClickItem(controller: DeletePhotosViewController, photos: [PhotoModel], index: Int)
}

class DeletePhotosViewController: ViewController {
    
    weak var delegate: DeletePhotosViewControllerDelegate?
    
    var viewModel: SecretPhotoViewModel!
    
    let itemsRelay = BehaviorRelay<[PhotoModel]>(value: [])
    let deleteRelay = PublishRelay<[PhotoModel]>()
    let showEmpty = BehaviorRelay<Bool>(value: false)
    
    var mbEventSelectedAll: String?
    var mbDeleteAll: String?
    var mbStayTimeEvent: String?
    
    private let deleteBtn = UIButton()
    private var itemDisposeBag = DisposeBag()
    private var selectedPhotos = [PhotoModel]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let m = 3.uiX
        let w = (UIDevice.screenWidth - 3*m)/4.0
        layout.itemSize = .init(width: w, height: w)
        layout.minimumLineSpacing = m
        layout.minimumInteritemSpacing = m
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 133.uiX + UIDevice.safeAreaBottom, right: 0)
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
            if let eventID = self.mbDeleteAll {
                MobClick.event(eventID)
            }
            if self.selectedPhotos.count == 0 {
                return
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
                PhotoManager.shared.delete(photos: self.selectedPhotos) {[weak self] s in
                    guard let self = self else { return }
                    self.deleteRelay.accept(self.selectedPhotos)
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
       
        itemsRelay.bind(to: collectionView.rx.items(cellIdentifier: PhotoListCollectionCell.reuseIdentifier, cellType: PhotoListCollectionCell.self)) { (row, element, cell) in
            cell.photoModel = element
        }.disposed(by: rx.disposeBag)
        
        itemsRelay.subscribe(onNext: { [weak self] items in
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
            let models = self.itemsRelay.value
            self.delegate?.secretPhotoDidClickItem(controller: self, photos: models, index: indexPath.row)
        }).disposed(by: rx.disposeBag)
        
        showEmpty.bind(to: rx.showEmptyView(imageName: "zwkqlzp-icon", title: "暂无可清理照片",inset: .init(top: 30.uiX, left: 0, bottom: 0, right: 0))).disposed(by: rx.disposeBag)
        showEmpty.bind(to: deleteBtn.rx.isHidden).disposed(by: rx.disposeBag)
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        view.backgroundColor = .init(hex: "#FFFFFF")
        
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
        if itemsRelay.value.isEmpty {
            navigationItem.rightBarButtonItem = nil
            return
        }
        if selectedPhotos.count == itemsRelay.value.count {
            chooseBtn.setAttributedTitle(.init(string: "取消全部", attributes: [
                .font: UIFont(style: .regular, size: 14.uiX),
                .foregroundColor: UIColor(hex: "#009CFF")
            ]), for: .normal)
            chooseBtn.sizeToFit()
            chooseBtn.rx.tap.subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if let eventID = self.mbEventSelectedAll {
                    MobClick.event(eventID)
                }
                self.itemsRelay.value.forEach{$0.selectedType.accept(.deselected)}
            }).disposed(by: rx.disposeBag)
        } else {
            chooseBtn.setAttributedTitle(.init(string: "选择全部", attributes: [
                .font: UIFont(style: .regular, size: 14.uiX),
                .foregroundColor: UIColor(hex: "#009CFF")
            ]), for: .normal)
            chooseBtn.sizeToFit()
            chooseBtn.rx.tap.subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if let eventID = self.mbEventSelectedAll {
                    MobClick.event(eventID)
                }
                self.itemsRelay.value.forEach{$0.selectedType.accept(.selected)}
            }).disposed(by: rx.disposeBag)
        }
        
        navigationItem.rightBarButtonItem = .init(customView: chooseBtn)
    }
    
}
