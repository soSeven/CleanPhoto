//
//  PhotoListCollectionCell.swift
//  Clean
//
//  Created by liqi on 2020/10/28.
//

import RxCocoa
import RxSwift

class PhotoListCollectionCell: CollectionViewCell {
    
    var representedAssetIdentifier: String!
    
    let imgView = UIImageView()
    let selectedBtn = MusicButton()
    var isShowSelectedBtn = true
    let bestMarkImgView = UIImageView()
    let bestLbl = UILabel()
    let timeLbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(selectedBtn)
        selectedBtn.setBackgroundImage(.create("wxz-icon"), for: .normal)
        selectedBtn.setBackgroundImage(.create("xz-icon"), for: .selected)
        contentView.addSubview(selectedBtn)
        selectedBtn.snp.makeConstraints { make in
            make.width.equalTo(19.uiX)
            make.height.equalTo(19.uiX)
            make.right.equalToSuperview().offset(-3.uiX)
            make.top.equalToSuperview().offset(3.uiX)
        }
        
        selectedBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            if let p = self.photoModel {
                switch p.selectedType.value {
                case .deselected:
                    p.selectedType.accept(.selected)
                case .selected:
                    p.selectedType.accept(.deselected)
                }
            }
        }).disposed(by: rx.disposeBag)
        
        let bestImg = UIImage.create("zjzp-tp")
        bestMarkImgView.image = bestImg
        contentView.addSubview(bestMarkImgView)
        bestMarkImgView.snp.makeConstraints { make in
            make.size.equalTo(bestImg.snpSize)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12.uiX)
        }
        
        bestLbl.text = "最佳照片"
        bestLbl.font = .init(style: .regular, size: 13.uiX)
        bestLbl.textColor = .init(hex: "#ffffff")
        bestMarkImgView.addSubview(bestLbl)
        bestLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        timeLbl.text = "00:00"
        timeLbl.font = .init(style: .regular, size: 12.uiX)
        timeLbl.textColor = .init(hex: "#ffffff")
        contentView.addSubview(timeLbl)
        timeLbl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-3.5.uiX)
            make.left.equalToSuperview().offset(4.5.uiX)
        }
        
        bestMarkImgView.isHidden = true
        timeLbl.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var photoModel: PhotoModel? {
        didSet {
            if let photoModel = photoModel {
                
                selectedBtn.isHidden = !isShowSelectedBtn
                if photoModel.isFromLocal {
                    imgView.image = photoModel.thumbImage
                } else {
                    let asset = photoModel.asset
                    let isImage = (asset.mediaType == .image)
                    bestLbl.text = isImage ? "最佳照片" : "最佳视频"
                    if !isImage {
                        let d = Int(asset.duration)
                        let m = d / 60
                        let s = d % 60
                        timeLbl.text = String(format: "%.2d:%.2d", m, s)
                    }
                    representedAssetIdentifier = asset.localIdentifier
                    PHCacheManager.cache.requestImage(for: asset,
                                                      targetSize: PHCacheManager.getTargetCellSize(),
                                                      contentMode: .aspectFill,
                                                      options: nil) {[weak self] image, _ in
                        guard let self = self else { return }
                        if self.representedAssetIdentifier == asset.localIdentifier && image != nil {
                            self.imgView.image = image
                            photoModel.thumbImage = image
                        }
                    }
                }
                cellDisposeBag = DisposeBag()
                photoModel.selectedType.bind {[weak self] type in
                    guard let self = self else { return }
                    if !self.isShowSelectedBtn {
                        return
                    }
                    switch type {
                    case .deselected:
                        self.selectedBtn.isHidden = false
                        self.selectedBtn.isSelected = false
                    case .selected:
                        self.selectedBtn.isHidden = false
                        self.selectedBtn.isSelected = true
                    }
                }.disposed(by: cellDisposeBag)
            }
        }
    }
    
    
}
