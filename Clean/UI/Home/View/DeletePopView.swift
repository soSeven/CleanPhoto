//
//  DeletePopView.swift
//  Clean
//
//  Created by liqi on 2020/10/31.
//

import SwiftEntryKit

class DeletePopView: UIView {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#1A1A1A")
        lbl.font = .init(style: .medium, size: 17.uiX)
        lbl.text = "允许删除照片？"
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    lazy var leftBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 15.uiX),
            .foregroundColor: UIColor(hex: "#009CFF"),
        ]
        b.setAttributedTitle(.init(string: "不允许", attributes: att), for: .normal)
        b.borderColor = .init(hex: "#009CFF")
        b.borderWidth = 0.5
        return b
    }()
    
    lazy var rightBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 15.uiX),
            .foregroundColor: UIColor(hex: "#FFFFFF"),
        ]
        b.setAttributedTitle(.init(string: "确认", attributes: att), for: .normal)
        b.backgroundColor = .init(hex: "#009CFF")
        return b
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        addSubview(titleLbl)
        addSubview(imgView)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        titleLbl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22.uiX)
            make.left.equalToSuperview().offset(20.uiX)
            make.right.equalToSuperview().offset(-20.uiX)
        }
        
        imgView.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(20.uiX)
            make.centerX.equalToSuperview()
            make.width.equalTo(100.uiX)
            make.height.equalTo(100.uiX)
        }
        
        leftBtn.cornerRadius = 22.uiX
        leftBtn.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(30.uiX)
            make.left.equalToSuperview().offset(19.uiX)
            make.bottom.equalToSuperview().offset(-20.uiX)
            make.height.equalTo(44.uiX)
            make.width.equalTo(128.uiX)
        }
        
        rightBtn.cornerRadius = 22.uiX
        rightBtn.snp.makeConstraints { make in
            make.top.equalTo(leftBtn.snp.top)
            make.right.equalToSuperview().offset(-19.uiX)
//            make.bottom.equalToSuperview().offset(-20.uiX)
            make.width.equalTo(leftBtn.snp.width)
            make.height.equalTo(leftBtn.snp.height)
        }
        
        snp.makeConstraints { make in
            make.width.equalTo(305.uiX)
        }
        
        leftBtn.rx.tap.subscribe(onNext: { _ in
            SwiftEntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        rightBtn.rx.tap.subscribe(onNext: { _ in
            SwiftEntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        cornerRadius = 10.uiX
    }
    
    
    // MARK: - Show
    
    func show() {
        
        var attributes = EKAttributes.centerFloat
        
        attributes.screenBackground = .color(color: .init(.init(white: 0, alpha: 0.6)))
        attributes.entryBackground = .color(color: .init(.init(hex: "#F7F7F7")))
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.displayDuration = .infinity
        attributes.roundCorners = .all(radius: 8.uiX)
        
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        
        SwiftEntryKit.display(entry: self, using: attributes)
    }
    
}
