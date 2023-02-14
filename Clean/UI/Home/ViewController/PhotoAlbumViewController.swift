//
//  PhotoAlbumViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/29.
//

import RxCocoa
import RxSwift

class PhotoAlbumViewController: ViewController {
    
    weak var delegate: SecretPhotoViewControllerDelegate?
    var viewModel: PhotoAblumViewModel!
    
    let selectedRelay = PublishRelay<[PhotoModel]>()
    
    private let right = MusicButton()
    
    private lazy var collectionView: UICollectionView = {
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
    
    private lazy var numberLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "将文件导入到你的空间"
        lbl.font = .init(style: .regular, size: 12.uiX)
        lbl.textColor = .init(hex: "#808080")
        lbl.textAlignment = .center
        return lbl
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
       
        let input = PhotoAblumViewModel.Input()
        let output = viewModel.transform(input: input)
       
        output.items.bind(to: collectionView.rx.items(cellIdentifier: PhotoListCollectionCell.reuseIdentifier, cellType: PhotoListCollectionCell.self)) { (row, element, cell) in
            cell.photoModel = element
            cell.selectedBtn.isUserInteractionEnabled = false
        }.disposed(by: rx.disposeBag)

        collectionView.rx.itemSelected.subscribe(onNext: { index in
            let p = output.items.value[index.row]
            switch p.selectedType.value {
            case .deselected:
                p.selectedType.accept(.selected)
            case .selected:
                p.selectedType.accept(.deselected)
            }
        }).disposed(by: rx.disposeBag)
        
        output.selected.subscribe(onNext: {[weak self] items in
            guard let self = self else { return }
            if items.count == 0 {
                self.numberLbl.text = "将文件导入到你的空间"
            } else {
                self.numberLbl.text = "将\(items.count)个文件导入到你的空间"
            }
        }).disposed(by: rx.disposeBag)
        
        right.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            self.selectedRelay.accept(output.selected.value)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        viewModel.loading.asObservable().bind(to: view.rx.mbHudLoaing).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        navigationItem.title = "所有照片"
        
        let leftTitleAtt: [NSAttributedString.Key : Any] = [
            .font: UIFont(style: .medium, size: 14.uiX),
            .foregroundColor: UIColor(hex: "#009CFF")
        ]
        
        right.setAttributedTitle(.init(string: "完成", attributes: leftTitleAtt), for: .normal)
        right.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: right)
        
        let left = MusicButton()
        left.setAttributedTitle(.init(string: "取消", attributes: leftTitleAtt), for: .normal)
        left.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: left)
        left.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        view.backgroundColor = .init(hex: "#FFFFFF")
        
        view.addSubview(numberLbl)
        numberLbl.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(6.uiX)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(numberLbl.snp.bottom).offset(13.uiX)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
}
