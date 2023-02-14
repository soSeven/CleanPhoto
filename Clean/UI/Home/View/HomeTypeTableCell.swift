//
//  HomeTypeTableCell.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import UIKit

class HomeTypeTableCell: TableViewCell {
    
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
        lbl.text = "屏幕截图、相似照片、相似视频、类似动 态图、连拍照片"
        lbl.numberOfLines = 0
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
            make.height.equalTo(95.uiX).priority(900)
        }
        
        let s = UIStackView(arrangedSubviews: [titleLbl, contentLbl], axis: .vertical, spacing: 5.uiX, alignment: .leading, distribution: .equalSpacing)
        
        bgView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(17.uiX)
            make.centerY.equalToSuperview()
            make.width.equalTo(56.5.uiX)
            make.height.equalTo(56.5.uiX)
        }
        
        bgView.addSubview(s)
        s.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(17.uiX)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-21.uiX)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(type: HomeType) {
        imgView.image = .create(type.imgName)
        titleLbl.text = type.title
        contentLbl.text = type.content
    }
}
