//
//  MessageAlertView.swift
//  Clean
//
//  Created by liqi on 2020/11/12.
//

import SwiftEntryKit

class MessageAlertView: UIView {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#1A1A1A")
        lbl.font = .init(style: .medium, size: 17.uiX)
        lbl.text = "确认退出？"
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var contentLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#8F8F8F")
        lbl.font = .init(style: .regular, size: 15.uiX)
        lbl.text = "退出将会丢失当前的搜索进度。"
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var leftBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 15.uiX),
            .foregroundColor: UIColor(hex: "#009CFF"),
        ]
        b.setAttributedTitle(.init(string: "取消", attributes: att), for: .normal)
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
        addSubview(contentLbl)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        titleLbl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22.uiX)
            make.left.equalToSuperview().offset(20.uiX)
            make.right.equalToSuperview().offset(-20.uiX)
        }
        
        contentLbl.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(35.uiX)
            make.left.equalToSuperview().offset(15.uiX)
            make.right.equalToSuperview().offset(-15.uiX)
        }
        
        leftBtn.cornerRadius = 22.uiX
        leftBtn.snp.makeConstraints { make in
            make.top.equalTo(contentLbl.snp.bottom).offset(54.uiX)
            make.left.equalToSuperview().offset(19.uiX)
            make.bottom.equalToSuperview().offset(-20.uiX)
            make.height.equalTo(44.uiX)
            make.width.equalTo(128.uiX)
        }
        
        rightBtn.cornerRadius = 22.uiX
        rightBtn.snp.makeConstraints { make in
            make.top.equalTo(leftBtn.snp.top)
            make.right.equalToSuperview().offset(-19.uiX)
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

