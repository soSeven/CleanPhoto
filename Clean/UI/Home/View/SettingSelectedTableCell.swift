//
//  SettingSelectedTableCell.swift
//  Clean
//
//  Created by liqi on 2020/11/2.
//

import RxCocoa
import RxSwift

class SettingSelectedTableCell: TableViewCell {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .regular, size: 15.uiX)
        lbl.textColor = .init(hex: "#1A1A1A")
        lbl.text = "照片视频管理"
        return lbl
    }()
    
    lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    let lineView = UIView()
    let btn = MusicButton()
    let arrowImgView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        selectionStyle = .none
        
        lineView.backgroundColor = .init(hex: "#F5F5F5")
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.uiX)
            make.right.equalToSuperview().offset(-15.uiX)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        imgView.snp.makeConstraints { make in
            make.width.equalTo(34.uiX)
            make.height.equalTo(34.uiX)
        }
        
        let s = UIStackView(arrangedSubviews: [imgView, titleLbl], axis: .horizontal, spacing: 8.uiX, alignment: .center, distribution: .equalSpacing)
        
        contentView.addSubview(s)
        s.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.uiX)
            make.centerY.equalToSuperview()
        }
        
        let normalImg = UIImage.create("gb-icon")
        let selectedImg = UIImage.create("dk-icon")
        btn.setBackgroundImage(normalImg, for: .normal)
        btn.setBackgroundImage(selectedImg, for: .selected)
        contentView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15.uiX)
            make.centerY.equalToSuperview()
            make.size.equalTo(normalImg.snpSize)
        }
        
        let arrowImg = UIImage.create("ckxq-icon")
        arrowImgView.image = arrowImg
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15.uiX)
            make.size.equalTo(arrowImg.snpSize)
            make.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(type: SettingTypeModel) {
        
        cellDisposeBag = DisposeBag()
        
        imgView.image = .create(type.img)
        titleLbl.text = type.title
        type.selectedRelay.bind(to: btn.rx.isSelected).disposed(by: cellDisposeBag)
        btn.rx.tap.subscribe(onNext: {
            type.selectedEvent.accept(type)
        }).disposed(by: cellDisposeBag)
        switch type.type {
        case .question, .privacy, .userProtocol:
            imgView.isHidden = true
            btn.isHidden = true
            arrowImgView.isHidden = false
        case .changePassword:
            imgView.isHidden = false
            btn.isHidden = true
            arrowImgView.isHidden = false
        default:
            imgView.isHidden = false
            btn.isHidden = false
            arrowImgView.isHidden = true
        }
    }
}
