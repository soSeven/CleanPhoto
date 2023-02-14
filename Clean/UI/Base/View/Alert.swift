//
//  Alert.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/8.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit
import SwiftEntryKit

class MessageAlert: UIView {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#222222")
        lbl.font = .init(style: .regular, size: 18.uiX)
        lbl.text = "title"
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var msgLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#222222")
        lbl.font = .init(style: .regular, size: 14.uiX)
        lbl.numberOfLines = 0
        lbl.text = "message"
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var leftBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 16.uiX),
            .foregroundColor: UIColor(hex: "#666666"),
        ]
        b.setAttributedTitle(.init(string: "刷新", attributes: att), for: .normal)
        b.borderColor = .init(hex: "#EDEDED")
        b.borderWidth = 0.5
        return b
    }()
    
    lazy var rightBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 16.uiX),
            .foregroundColor: UIColor(hex: "#FF5050"),
        ]
        b.setAttributedTitle(.init(string: "去设置", attributes: att), for: .normal)
        b.borderColor = .init(hex: "#EDEDED")
        b.borderWidth = 0.5
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
        addSubview(msgLbl)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        titleLbl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22.uiX)
            make.left.equalToSuperview().offset(30.uiX)
            make.right.equalToSuperview().offset(-30.uiX)
        }
        
        msgLbl.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(20.uiX)
            make.left.equalToSuperview().offset(30.uiX)
            make.right.equalToSuperview().offset(-30.uiX)
        }
        
        leftBtn.snp.makeConstraints { make in
            make.top.equalTo(msgLbl.snp.bottom).offset(30.uiX)
            make.left.bottom.equalToSuperview()
            make.height.equalTo(50.uiX)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.top.equalTo(leftBtn.snp.top)
            make.bottom.equalTo(leftBtn.snp.bottom)
            make.right.equalToSuperview()
            make.left.equalTo(leftBtn.snp.right)
            make.width.equalTo(leftBtn.snp.width)
        }
        
        snp.makeConstraints { make in
            make.width.equalTo(290.uiX)
        }
        
        leftBtn.rx.tap.subscribe(onNext: { _ in
            SwiftEntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        rightBtn.rx.tap.subscribe(onNext: { _ in
            SwiftEntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        cornerRadius = 8.uiX
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

class MessageDecideAlert: UIView {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#222222")
        lbl.font = .init(style: .regular, size: 18.uiX)
        lbl.text = "title"
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var msgLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#222222")
        lbl.font = .init(style: .regular, size: 14.uiX)
        lbl.numberOfLines = 0
        lbl.text = "message"
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var rightBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 16.uiX),
            .foregroundColor: UIColor(hex: "#ff5252"),
        ]
        b.setAttributedTitle(.init(string: "去设置", attributes: att), for: .normal)
        b.borderColor = .init(hex: "#EDEDED")
        b.borderWidth = 0.5
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
        addSubview(msgLbl)
        addSubview(rightBtn)
        
        titleLbl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22.uiX)
            make.left.equalToSuperview().offset(30.uiX)
            make.right.equalToSuperview().offset(-30.uiX)
        }
        
        msgLbl.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(20.uiX)
            make.left.equalToSuperview().offset(30.uiX)
            make.right.equalToSuperview().offset(-30.uiX)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.top.equalTo(msgLbl.snp.bottom).offset(30.uiX)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50.uiX)
        }
        
        snp.makeConstraints { make in
            make.width.equalTo(290.uiX)
        }
        
        cornerRadius = 8.uiX
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

class MessageAddAlert: UIView {
    
    let imgView = UIImageView()
    
    lazy var phonelbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#67677C")
        lbl.font = .init(style: .regular, size: 14.uiX)
        lbl.text = ""
        return lbl
    }()
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#393946")
        lbl.font = .init(style: .regular, size: 17.uiX)
        lbl.text = ""
        return lbl
    }()
    
    lazy var msgLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#393946")
        lbl.font = .init(style: .regular, size: 16.uiX)
        lbl.numberOfLines = 0
        lbl.text = ""
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var leftBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 16.uiX),
            .foregroundColor: UIColor(hex: "#222222"),
        ]
        b.setAttributedTitle(.init(string: "忽略", attributes: att), for: .normal)
        b.borderColor = .init(hex: "#EDEDED")
        b.borderWidth = 0.5
        return b
    }()
    
    lazy var rightBtn: UIButton = {
        let b = UIButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 16.uiX),
            .foregroundColor: UIColor(hex: "#222222"),
        ]
        b.setAttributedTitle(.init(string: "确定", attributes: att), for: .normal)
        b.borderColor = .init(hex: "#EDEDED")
        b.borderWidth = 0.5
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
        
        let v = UIView()
        imgView.cornerRadius = 22.uiX
        v.addSubview(titleLbl)
        v.addSubview(imgView)
        v.addSubview(phonelbl)
        
        imgView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(44.uiX)
            make.height.equalTo(44.uiX)
        }
        
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(11.uiX)
            make.top.right.equalToSuperview()
        }
        
        phonelbl.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(11.uiX)
            make.bottom.right.equalToSuperview()
        }
        
        addSubview(v)
        addSubview(msgLbl)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        v.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22.uiX)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(200.uiX)
        }
        
        msgLbl.snp.makeConstraints { make in
            make.top.equalTo(v.snp.bottom).offset(20.uiX)
            make.left.equalToSuperview().offset(30.uiX)
            make.right.equalToSuperview().offset(-30.uiX)
        }
        
        leftBtn.snp.makeConstraints { make in
            make.top.equalTo(msgLbl.snp.bottom).offset(30.uiX)
            make.left.bottom.equalToSuperview()
            make.height.equalTo(50.uiX)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.top.equalTo(leftBtn.snp.top)
            make.bottom.equalTo(leftBtn.snp.bottom)
            make.right.equalToSuperview()
            make.left.equalTo(leftBtn.snp.right)
            make.width.equalTo(leftBtn.snp.width)
        }
        
        snp.makeConstraints { make in
            make.width.equalTo(290.uiX)
        }
        
//        leftBtn.rx.tap.subscribe(onNext: { _ in
//            SwiftEntryKit.dismiss()
//        }).disposed(by: rx.disposeBag)
//        
//        rightBtn.rx.tap.subscribe(onNext: { _ in
//            SwiftEntryKit.dismiss()
//        }).disposed(by: rx.disposeBag)
        
        cornerRadius = 8.uiX
    }
    
    
    // MARK: - Show
    
    func show() {
        
        var attributes = EKAttributes.centerFloat
        
        attributes.screenBackground = .color(color: .init(.init(white: 0, alpha: 0.6)))
        attributes.entryBackground = .color(color: .init(.init(hex: "#F7F7F7")))
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
//        attributes.scroll = .disabled
        attributes.displayDuration = .infinity
        attributes.roundCorners = .all(radius: 8.uiX)
        
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        
        SwiftEntryKit.display(entry: self, using: attributes)
    }
    
}

