//
//  AddressCollectionCell.swift
//  Clean
//
//  Created by liqi on 2020/11/5.
//

import RxCocoa
import RxSwift

class AddressCollectionCell: CollectionViewCell {
    
    var representedAssetIdentifier: String!
    
    let imgView = UIImageView()

    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .regular, size: 15.uiX)
        lbl.textColor = .init(hex: "#1A1A1A")
        lbl.text = "其他"
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView.cornerRadius = 5.uiX
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.snp.makeConstraints { make in
            make.width.equalTo(167.5.uiX)
            make.height.equalTo(167.5.uiX)
        }
        
        titleLbl.snp.makeConstraints { make in
            make.width.equalTo(167.uiX)
        }
        
        let s = UIStackView(arrangedSubviews: [imgView, titleLbl], axis: .vertical, spacing: 5.uiX, alignment: .leading, distribution: .equalSpacing)
        
        contentView.addSubview(s)
        s.snp.makeConstraints { make in
            make.edges.equalToSuperview().priority(900)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(photos: [PhotoModel]) {
        if let photoModel = photos.first {
            titleLbl.text = (photoModel.address ?? "其他") + "  \(photos.count)"
            if photoModel.isFromLocal {
                imgView.image = photoModel.thumbImage
            } else {
                let asset = photoModel.asset
                representedAssetIdentifier = asset.localIdentifier
                PHCacheManager.cache.requestImage(for: asset,
                                                  targetSize: PHCacheManager.getTargetCellSize(),
                                                  contentMode: .aspectFill,
                                                  options: nil) {[weak self] image, _ in
                    guard let self = self else { return }
                    if self.representedAssetIdentifier == asset.localIdentifier && image != nil {
                        self.imgView.image = image
                    }
                }
            }
        }
    }
    
}
