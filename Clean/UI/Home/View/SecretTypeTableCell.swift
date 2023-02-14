//
//  SecretTypeTableCell.swift
//  Clean
//
//  Created by liqi on 2020/10/29.
//

import UIKit

class SecretTypeTableCell: TableViewCell {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .bold, size: 21.uiX)
        lbl.textColor = .init(hex: "#FFFFFF")
        lbl.text = "照片视频管理"
        return lbl
    }()
    
    lazy var contentLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .regular, size: 14.uiX)
        lbl.textColor = .init(hex: "#C7E0FF")
        lbl.text = "屏幕截图、相似照片、相似视频、类似动 态图、连拍照片"
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
        
        let s = UIStackView(arrangedSubviews: [titleLbl, contentLbl], axis: .vertical, spacing: 5.uiX, alignment: .leading, distribution: .equalSpacing)
        
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-7.uiX)
            make.width.equalTo(345.uiX)
            make.height.equalTo(140.uiX).priority(900)
        }
        
        imgView.addSubview(s)
        s.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.uiX)
            make.top.equalToSuperview().offset(36.uiX)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(type: SecretType) {
        imgView.image = .create(type.imgName)
        titleLbl.text = type.title
        contentLbl.text = type.content
        contentLbl.textColor = type.contentColor
    }
}
