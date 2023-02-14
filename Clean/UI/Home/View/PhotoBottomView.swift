//
//  PhotoBottomView.swift
//  Clean
//
//  Created by liqi on 2020/10/28.
//

import RxSwift
import RxCocoa

class PhotoBottomView: UIView {
    
    var didClickItem: ((Int)->())?
    
    let photosRelay = BehaviorRelay<[PhotoModel]>(value: [])
    
    private var scrollIndex = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let m = 10.uiX
        let w = 79.uiX
        layout.itemSize = .init(width: w, height: w)
        layout.minimumLineSpacing = m
        layout.minimumInteritemSpacing = m
        layout.sectionInset = .init(top: 0, left: 10.uiX, bottom: 0, right: 10.uiX)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(cellType: PhotoListCollectionCell.self)
        
        return collectionView
    }()
    
    lazy var numberLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#808080")
        lbl.font = .init(style: .regular, size: 13.uiX)
        lbl.text = "0/0"
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(numberLbl)
        numberLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8.uiX)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(33.uiX)
            make.left.right.equalToSuperview()
            make.height.equalTo(80.uiX)
        }
        
        setupBinding()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scroll(to: scrollIndex, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scroll(to index: Int, animated: Bool) {
        scrollIndex = index
        if scrollIndex < collectionView.numberOfItems(inSection: 0) {
            collectionView.scrollToItem(at: .init(row: scrollIndex, section: 0), at: .centeredHorizontally, animated: animated)
        }
        
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        photosRelay.bind(to: collectionView.rx.items(cellIdentifier: PhotoListCollectionCell.reuseIdentifier, cellType: PhotoListCollectionCell.self)) { (row, element, cell) in
            cell.isShowSelectedBtn = false
            cell.photoModel = element
        }.disposed(by: rx.disposeBag)

        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            self.didClickItem?(index.row)
        }).disposed(by: rx.disposeBag)
    }
    
}


