//
//  SimilarHeaderView.swift
//  Clean
//
//  Created by liqi on 2020/11/6.
//

import UIKit
import Reusable

class SimilarHeaderView: UICollectionReusableView, Reusable {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#666666")
        lbl.font = .init(style: .regular, size: 13.uiX)
        lbl.text = "0张照片"
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
