//
//  SecretPhotoViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/29.
//

import Photos
import RxSwift
import RxCocoa
import MBProgressHUD

protocol SecretPhotoViewControllerDelegate: AnyObject {
    
    func secretPhotoDidClickItem(controller: SecretPhotoViewController, photos: [PhotoModel], index: Int)
    func secretPhotoDidClickAblum(controller: SecretPhotoViewController)
    func secretPhotoDidClickDelete(controller: SecretPhotoViewController, photos: [PhotoModel])
}

class SecretPhotoViewController: ViewController {
    
    weak var delegate: SecretPhotoViewControllerDelegate?
    
    var viewModel: SecretPhotoViewModel!
    
    let addItemsRelay = PublishRelay<[PhotoModel]>()
    let deleteRelay = PublishRelay<[PhotoModel]>()
    
    private let addBtn = UIButton()
    private let chooseBtn = MusicButton()
    
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
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 20.uiX + UIDevice.safeAreaBottom, right: 0)
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
        MobClick.beginEvent("private_stay")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endEvent("private_stay")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Binding
    
    private func setupBinding() {
        
        addBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            MobClick.event("add_photos")
            self.delegate?.secretPhotoDidClickAblum(controller: self)
        }).disposed(by: rx.disposeBag)
        
        let input = SecretPhotoViewModel.Input(addItems: addItemsRelay.asObservable(), deleteItems: deleteRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        chooseBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            let models = output.items.value
            MobClick.event("select_button")
            self.delegate?.secretPhotoDidClickDelete(controller: self, photos: models)
        }).disposed(by: rx.disposeBag)
       
        output.items.bind(to: collectionView.rx.items(cellIdentifier: PhotoListCollectionCell.reuseIdentifier, cellType: PhotoListCollectionCell.self)) { (row, element, cell) in
            cell.isShowSelectedBtn = false
            cell.photoModel = element
        }.disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let self = self else { return }
            let models = output.items.value
            self.delegate?.secretPhotoDidClickItem(controller: self, photos: models, index: indexPath.row)
        }).disposed(by: rx.disposeBag)
        
        var mb: MBProgressHUD?
        output.addProgress.subscribe(onNext: {[weak self] (progress, finished) in
            guard let self = self else { return }
            guard let window = self.view.window else { return }
            if finished {
                mb?.completionBlock = {
                    mb = nil
                }
                mb?.hide(animated: true)
            } else {
                if mb == nil {
                    mb = MBProgressHUD.showAdded(to: window, animated: true)
                }
                mb?.mode = .determinateHorizontalBar
                mb?.contentColor = UIColor.systemBlue
                mb?.progress = progress
            }
            
        }).disposed(by: rx.disposeBag)
        
        output.endProgress.subscribe(onNext: { items in
            
            let key = "pop_delete_photo"
            if let _ = UserDefaults.standard.object(forKey: key) {
                if !UserConfigure.shared.isDeletePhoto.value {
                    return
                }
                PhotoManager.shared.delete(photos: items, success: { successItems in
                    
                })
            } else {
                UserDefaults.standard.setValue(key, forKey: key)
                let popup = MessageAlertView()
                popup.titleLbl.text = "导入后是否删除相片？"
                popup.contentLbl.text = "选择确认将会在导入后删除相片，可以在设置页面中重新设置"
                popup.leftBtn.rx.tap.subscribe(onNext: {
                    
                }).disposed(by: popup.rx.disposeBag)
                popup.rightBtn.rx.tap.subscribe(onNext: {
                    UserConfigure.shared.isDeletePhoto.accept(true)
                    PhotoManager.shared.delete(photos: items, success: { successItems in
                        
                    })
                }).disposed(by: popup.rx.disposeBag)
                popup.show()
            }
        }).disposed(by: rx.disposeBag)
        
        output.showEmpty.distinctUntilChanged().bind(to: rx.showEmptyView(imageName: "zwkqlzp-icon", title: "暂无可清理照片",inset: .init(top: 30.uiX, left: 0, bottom: 0, right: 0), addBottom: true)).disposed(by: rx.disposeBag)
        output.showEmpty.distinctUntilChanged().bind(to: chooseBtn.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.loading.asObservable().bind(to: view.rx.mbHudLoaing).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        navigationItem.title = "私密空间"
        view.backgroundColor = .init(hex: "#FFFFFF")
        
        chooseBtn.setAttributedTitle(.init(string: "选择", attributes: [
            .font: UIFont(style: .regular, size: 14.uiX),
            .foregroundColor: UIColor(hex: "#009CFF")
        ]), for: .normal)
        chooseBtn.sizeToFit()
        navigationItem.rightBarButtonItem = .init(customView: chooseBtn)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let addBtnImg = UIImage.create("smkj-tj-icon")
        addBtn.setBackgroundImage(addBtnImg, for: .normal)
        view.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.size.equalTo(addBtnImg.snpSize)
            make.bottom.equalToSuperview().offset(-45.uiX)
            make.right.equalToSuperview().offset(-13.uiX)
        }
    }
    
}
