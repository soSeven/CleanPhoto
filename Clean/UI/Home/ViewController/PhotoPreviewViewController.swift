//
//  PhotoPreviewViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/28.
//

import Photos
import RxSwift
import RxCocoa

class PhotoPreviewViewController: ViewController {
    
    static let previewVCScrollNotification = Notification.Name("PhonePreviewViewControllerScrollNotification")
    
    private let cellItemSpacing: CGFloat = 40
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(cellType: PhotoPreviewCell.self)
        collectionView.register(cellType: GifPreviewCell.self)
        collectionView.register(cellType: VideoPreviewCell.self)
        collectionView.register(cellType: LivePhotoPewviewCell.self)
        collectionView.register(cellType: NetVideoPreviewCell.self)
        collectionView.register(cellType: LocalImagePreviewCell.self)
        
        return collectionView
    }()
    
    var currentIndex: Int = 0
    let photosRelay = BehaviorRelay<[PhotoModel]>(value: [])
    let deleteRelay = PublishRelay<[PhotoModel]>()
    
    private let navView = UIView()
    private let bottomView = PhotoBottomView()
    
    private var hideNavView = false
    private var isFirstLayout = true
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override func onceWhenViewDidAppear(_ animated: Bool) {
        super.onceWhenViewDidAppear(animated)
        reloadCurrentCell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: -cellItemSpacing / 2, y: 0, width: view.width + cellItemSpacing, height: view.height)
        
        let navH = UIDevice.navigationBarHeight
        navView.frame = CGRect(x: 0, y: 0, width: view.width, height: navH)
        
        let bottomH = UIDevice.safeAreaBottom + 128.uiX
        bottomView.frame = CGRect(x: 0, y: view.height - bottomH, width: view.width, height: bottomH)
        
        guard isFirstLayout else { return }
        isFirstLayout = false
        if currentIndex > 0 {
            collectionView.contentOffset = CGPoint(x: (view.width + cellItemSpacing) * CGFloat(currentIndex), y: 0)
            bottomView.scroll(to: currentIndex, animated: false)
            bottomView.numberLbl.text = "\(currentIndex + 1)/\(photosRelay.value.count)"
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return hideNavView ? .lightContent : .default
    }
    
    deinit {
        print("\(self)")
    }
    
    // MARK: - Event
    
    @objc
    private func onClickBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func onClickDelete() {
        let model = photosRelay.value[currentIndex]
        if model.isFromLocal {
            let delete = DeletePopView()
            delete.imgView.image = model.thumbImage
            delete.rightBtn.rx.tap.subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                var models = self.photosRelay.value
                models.removeAll(model)
                self.photosRelay.accept(models)
                if self.currentIndex > models.count - 1 {
                    self.currentIndex = models.count - 1
                }
                self.onClickBottomItem(index: self.currentIndex)
                self.deleteRelay.accept([model])
            }).disposed(by: rx.disposeBag)
            delete.show()
        } else {
            PhotoManager.shared.delete(photos: [model], success: {[weak self] models in
                guard let self = self else { return }
                if models.isEmpty {
                    return
                }
                var currentModels = self.photosRelay.value
                currentModels.removeAll(model)
                self.photosRelay.accept(currentModels)
                if self.currentIndex > currentModels.count - 1 {
                    self.currentIndex = currentModels.count - 1
                }
                self.onClickBottomItem(index: self.currentIndex)
                self.deleteRelay.accept(models)
            })
        }
    }
    
    private func onClickBottomItem(index: Int) {
        currentIndex = index
        collectionView.contentOffset = CGPoint(x: (view.width + cellItemSpacing) * CGFloat(currentIndex), y: 0)
        bottomView.scroll(to: currentIndex, animated: true)
        bottomView.numberLbl.text = "\(currentIndex + 1)/\(photosRelay.value.count)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadCurrentCell()
        }
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        photosRelay.subscribe(onNext: {[weak self] items in
            guard let self = self else { return }
            if items.isEmpty {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.bottomView.numberLbl.text = "\(self.currentIndex + 1)/\(items.count)"
            self.collectionView.reloadData()
        }).disposed(by: rx.disposeBag)
        photosRelay.bind(to: bottomView.photosRelay).disposed(by: rx.disposeBag)
     
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        hbd_barHidden = true
        view.backgroundColor = .init(hex: "#FFFFFF")
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        navView.backgroundColor = .white
        view.addSubview(navView)
        
        bottomView.backgroundColor = .white
        bottomView.didClickItem = { [weak self] index in
            guard let self = self else { return }
            self.onClickBottomItem(index: index)
        }
        view.addSubview(bottomView)
        
        let backBtn = UIButton()
        backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        backBtn.setImage(UIImage(named: "fh-icon"), for: .normal)
        navView.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalTo(40.uiX)
            make.height.equalTo(44.uiX)
        }
        
        let deleteBtn = UIButton()
        deleteBtn.addTarget(self, action: #selector(onClickDelete), for: .touchUpInside)
        deleteBtn.setAttributedTitle(.init(string: "删除", attributes: [
            .font: UIFont(style: .regular, size: 14.uiX),
            .foregroundColor: UIColor(hex: "#009CFF")
        ]), for: .normal)
        navView.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
    }
    
}

extension PhotoPreviewViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = photosRelay.value[indexPath.row]
        let baseCell: PreviewBaseCell
        if model.isFromLocal {
            if model.type == .video {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: NetVideoPreviewCell.self)
                cell.videoUrl = model.localURL
                baseCell = cell
            } else {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: LocalImagePreviewCell.self)
                cell.image = UIImage(contentsOfFile: model.localURL?.path ?? "")
                baseCell = cell
            }
        } else {
            if model.type == .gif {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: GifPreviewCell.self)
                cell.model = model
                baseCell = cell
            } else if model.type == .livePhoto {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: LivePhotoPewviewCell.self)
                cell.model = model
                baseCell = cell
            } else if model.type == .video {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: VideoPreviewCell.self)
                cell.model = model
                baseCell = cell
            } else {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PhotoPreviewCell.self)
                cell.model = model
                baseCell = cell
            }
        }
        
        baseCell.singleTapBlock = { [weak self] in
            guard let self = self else { return }
            self.tapPreviewCell()
        }
        return baseCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosRelay.value.count
    }
    
    func tapPreviewCell() {
        self.hideNavView = !self.hideNavView
        let currentCell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0))
        if let cell = currentCell as? VideoPreviewCell {
            if cell.isPlaying {
                self.hideNavView = true
            }
        }
        if let cell = currentCell as? NetVideoPreviewCell {
            if cell.isPlaying {
                self.hideNavView = true
            }
        }
        self.navView.isHidden = self.hideNavView
        self.bottomView.isHidden = self.hideNavView
        view.backgroundColor = self.hideNavView ? .black : .white
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func reloadCurrentCell() {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) else {
            print("ddd")
            return
        }
        if let cell = cell as? GifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? LivePhotoPewviewCell {
            cell.loadLivePhotoData()
        }
    }
    
}

extension PhotoPreviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellItemSpacing/2, bottom: 0, right: cellItemSpacing/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: view.height)
    }
    
}

extension PhotoPreviewViewController: UICollectionViewDelegate {
    
}

extension PhotoPreviewViewController {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionView else {
            return
        }
        NotificationCenter.default.post(name: PhotoPreviewViewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (self.view.bounds.width + cellItemSpacing)))
        page = max(0, min(page, photosRelay.value.count-1))
        if page == self.currentIndex {
            return
        }
        self.currentIndex = page
        bottomView.scroll(to: currentIndex, animated: true)
        bottomView.numberLbl.text = "\(currentIndex + 1)/\(photosRelay.value.count)"
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0))
        if let cell = cell as? GifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? LivePhotoPewviewCell {
            cell.loadLivePhotoData()
        }
    }
    
}

