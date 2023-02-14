//
//  PhotoManagerTableCell.swift
//  Clean
//
//  Created by liqi on 2020/11/4.
//

import RxCocoa
import RxSwift

class PhotoManagerTableCell: TableViewCell {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .medium, size: 15.uiX)
        lbl.textColor = .init(hex: "#333333")
        lbl.text = "照片视频管理"
        return lbl
    }()
    
    lazy var contentLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .regular, size: 13.uiX)
        lbl.textColor = .init(hex: "#808080")
        lbl.text = "0"
        return lbl
    }()
    
    lazy var activity: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .gray)
        a.startAnimating()
        return a
    }()
    
    let arrowImgView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.cornerRadius = 10.uiX
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 15.uiX, bottom: 10.uiX, right: 15.uiX))
            make.height.equalTo(49.uiX).priority(900)
        }
        
        bgView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.uiX)
            make.centerY.equalToSuperview()
        }
        
        let arrowImg = UIImage.create("glzptz-icon")
        arrowImgView.image = arrowImg
        bgView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.size.equalTo(arrowImg.snpSize)
        }
        
        let s = UIStackView(arrangedSubviews: [activity, contentLbl, arrowImgView], axis: .horizontal, spacing: 5.uiX, alignment: .center, distribution: .equalSpacing)
        
        bgView.addSubview(s)
        s.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-21.uiX)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(type: Album) {
        
        titleLbl.text = type.type.title
        
        cellDisposeBag = DisposeBag()
        
        switch type.type {
        case .similarPhoto, .similarVideo, .livePhoto, .similarMostPhoto:
            type.rangePhotosAlbum.subscribe(onNext: {[weak self] models in
                guard let self = self else { return }
                let count = models.map{$0.count}.reduce(0) { $0 + $1 }
                self.contentLbl.text = "\(count)张"
            }).disposed(by: cellDisposeBag)
        default:
            type.rangePhotos.subscribe(onNext: {[weak self] models in
                guard let self = self else { return }
                self.contentLbl.text = "\(models.count)张"
            }).disposed(by: cellDisposeBag)
        }
        
        
        type.loading.subscribe(onNext: {[weak self] loading in
            guard let self = self else { return }
            if loading {
                self.activity.startAnimating()
                self.contentLbl.isHidden = true
                self.arrowImgView.isHidden = true
            } else {
                self.activity.stopAnimating()
                self.contentLbl.isHidden = false
                self.arrowImgView.isHidden = false
            }
        }).disposed(by: cellDisposeBag)
        
    }
}
