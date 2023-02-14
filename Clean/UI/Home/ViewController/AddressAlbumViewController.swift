//
//  AddressAlbumViewController.swift
//  Clean
//
//  Created by liqi on 2020/11/4.
//

import Photos
import RxSwift
import RxCocoa
import MBProgressHUD

protocol AddressAlbumViewControllerDelegate: AnyObject {
    func addressDidClickDelete(controller: AddressAlbumViewController, photos: [PhotoModel])
}

class AddressAlbumViewController: ViewController {
    
    weak var delegate: AddressAlbumViewControllerDelegate?
    
    var viewModel: AddressAblumViewModel!
    
    let itemsRelay = BehaviorRelay<[PhotoModel]>(value: [])
    let deleteRelay = PublishRelay<[PhotoModel]>()
    
    private let addBtn = UIButton()
    private let chooseBtn = MusicButton()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLeftAlignedLayout()
        layout.estimatedItemSize = .init(width: 167.5.uiX, height: 10.uiX)
        layout.sectionInset = .init(top: 0, left: 15.uiX, bottom: 0, right: 15.uiX)
        layout.minimumLineSpacing = 15.uiX
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 20.uiX + UIDevice.safeAreaBottom, right: 0)
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(cellType: AddressCollectionCell.self)
        
        return collectionView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Binding
    
    private func setupBinding() {
        
        let input = AddressAblumViewModel.Input(request: itemsRelay.asObservable())
        let output = viewModel.transform(input: input)
       
        output.items.bind(to: collectionView.rx.items(cellIdentifier: AddressCollectionCell.reuseIdentifier, cellType: AddressCollectionCell.self)) { (row, element, cell) in
            cell.bind(photos: element)
        }.disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let self = self else { return }
            let models = output.items.value[indexPath.row]
            self.delegate?.addressDidClickDelete(controller: self, photos: models)
        }).disposed(by: rx.disposeBag)
        
        viewModel.loading.asObservable().bind(to: view.rx.mbHudLoaing).disposed(by: rx.disposeBag)
        
        output.items.flatMapLatest{Observable.just($0.isEmpty)}.bind(to: rx.showEmptyView(imageName: "zwkqlzp-icon", title: "暂无可清理照片",inset: .init(top: 30.uiX, left: 0, bottom: 0, right: 0))).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        navigationItem.title = "地址"
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
}
