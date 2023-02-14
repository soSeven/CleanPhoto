//
//  PayListCell.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/4.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit

class PayListCell: CollectionViewCell {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "半年卡"
        lbl.textAlignment = .center
        lbl.textColor = .init(hex: "#424242")
        lbl.font = .init(style: .medium, size: 13.uiX)
        return lbl
    }()
    
    lazy var priceLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "￥38"
        lbl.textAlignment = .center
        lbl.textColor = .init(hex: "#B38C59")
        lbl.font = .init(style: .medium, size: 26.uiX)
        return lbl
    }()
    
    lazy var bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.cornerRadius = 4.uiX
        v.borderWidth = 1.5.uiX
        v.borderColor = .init(hex: "#EEEEEE")
        return v
    }()
    
    lazy var markImgView: UIImageView = {
        let v = UIImageView(image: UIImage.create("hot-icon"))
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stack = UIStackView(arrangedSubviews: [titleLbl, priceLbl], axis: .vertical, spacing: 2.uiX, alignment: .center, distribution: .equalSpacing)
        
        
        bgView.addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addSubview(markImgView)
        markImgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-4.uiX)
            make.top.equalTo(bgView.snp.top).offset(-21.uiX)
            make.size.equalTo(markImgView.image!.snpSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(to model: PayProductModel, selected: Bool) {
        titleLbl.text = model.name
        priceLbl.attributedText = getCashStr(num: model.price)
        markImgView.isHidden = !model.isRecommend
        if selected {
            bgView.backgroundColor = .init(hex: "#FFF2D4")
            bgView.borderColor = .init(hex: "#FCC45C")
        } else {
            bgView.backgroundColor = .white
            bgView.borderColor = .init(hex: "#EEEEEE")
        }
    }
    
    private func getCashStr(num: String) -> NSAttributedString {
        let a1: [NSAttributedString.Key: Any] = [
            .font: UIFont(style: .bold, size: 14.uiX),
            .foregroundColor: UIColor(hex: "#9A5909")
        ]
        let a2: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "DIN-Medium", size: 25.uiX)!,
            .foregroundColor: UIColor(hex: "#9A5909")
        ]
        let s = NSMutableAttributedString(string: num)
        if s.length >= 2 {
            s.addAttributes(a1, range: .init(location: 0, length: 1))
            s.addAttributes(a2, range: .init(location: 1, length: s.length - 1))
        }
        return s
    }
    
}
