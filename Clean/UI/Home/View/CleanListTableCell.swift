//
//  CleanListTableCell.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import RxCocoa
import RxSwift

class CleanListTableCell: TableViewCell {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .medium, size: 15.uiX)
        lbl.textColor = .init(hex: "#333333")
        return lbl
    }()
    
    lazy var contentLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .regular, size: 13.uiX)
        lbl.textColor = .init(hex: "#808080")
        return lbl
    }()
    
    lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.cornerRadius = 10.uiX
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 15.uiX, bottom: 15.uiX, right: 15.uiX))
            make.height.equalTo(81.uiX).priority(900)
        }
        
        let s = UIStackView(arrangedSubviews: [titleLbl, contentLbl], axis: .vertical, spacing: 5.uiX, alignment: .leading, distribution: .equalSpacing)
        
        bgView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.uiX)
            make.centerY.equalToSuperview()
            make.width.equalTo(22.uiX)
            make.height.equalTo(22.uiX)
        }
        
        let arrowImg = UIImage.create("kqlwjtz-icon")
        let arrowImgView = UIImageView(image: arrowImg)
        bgView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14.uiX)
            make.centerY.equalToSuperview()
            make.size.equalTo(arrowImg.snpSize)
        }
        
        bgView.addSubview(s)
        s.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(15.uiX)
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
        
        imgView.rx.tap().subscribe(onNext: {
            type.selected.accept(!type.selected.value)
        }).disposed(by: cellDisposeBag)
        
        type.selected.subscribe(onNext: {[weak self] s in
            guard let self = self else { return }
            self.imgView.image = s ? .create("kqlwj-icon") : .create("wxz-icon")
        }).disposed(by: cellDisposeBag)
        
        switch type.type {
        case .similarPhoto, .similarVideo, .livePhoto, .similarMostPhoto:
            type.photosAlbum.subscribe(onNext: {[weak self] models in
                guard let self = self else { return }
                let count = models.map{$0.count}.reduce(0) { $0 + $1 } - models.count
                var space = 0
                for m in models {
                    space += m.reduce(0) { $0 + $1.dataLength}
                }
                self.contentLbl.text = "\(count)张 · \(UIDevice.fileSizeToString(fileSize: Int64(space)))"
            }).disposed(by: cellDisposeBag)
        default:
            type.photos.subscribe(onNext: {[weak self] models in
                guard let self = self else { return }
                let space = models.reduce(0) { $0 + $1.dataLength}
                self.contentLbl.text = "\(models.count)张 · \(UIDevice.fileSizeToString(fileSize: Int64(space)))"
            }).disposed(by: cellDisposeBag)
        }
    }
}


