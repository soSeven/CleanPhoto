//
//  PasswordPopView.swift
//  Clean
//
//  Created by liqi on 2020/11/3.
//

import SwiftEntryKit

class PasswordPopView: UIView {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .init(style: .medium, size: 16.uiX)
        lbl.text = "输入密码"
        return lbl
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = MusicButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .init(style: .medium, size: 16.uiX)
        return btn
    }()
    
    var successAction: (()->())?
    
    private var passwordContainerView: PasswordContainerView!
    
    init(needCancel: Bool = false) {
        super.init(frame: .zero)
        setupUI(needCancel: needCancel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func setupUI(needCancel: Bool) {
        
        let stackView = UIStackView()
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20.uiX, left: 0, bottom: 20.uiX, right: 0))
            make.width.equalTo(320)
        }
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20.uiX
        
        stackView.addArrangedSubview(titleLbl)

        passwordContainerView = PasswordContainerView.create(in: stackView, digit: 4)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "删除"
        
        if needCancel {
            stackView.addArrangedSubview(cancelBtn)
            cancelBtn.rx.tap.subscribe(onNext: {
                SwiftEntryKit.dismiss()
            }).disposed(by: rx.disposeBag)
        }
        
    }
    
    
    // MARK: - Show
    
    func show() {
        
        var attributes = EKAttributes.centerFloat
        
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.entryBackground = .color(color: .init(.clear))
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.displayDuration = .infinity
        attributes.roundCorners = .all(radius: 8.uiX)
        
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        
        attributes.name = "PasswordPopView"
        
        SwiftEntryKit.display(entry: self, using: attributes)
        
        if UserConfigure.shared.isHasTouchId {
            passwordContainerView.touchAuthentication()
        } else {
            passwordContainerView.touchAuthenticationEnabled = false
        }
        
    }
    
    static var isExist: Bool {
        return SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "PasswordPopView")
    }
    
}

extension PasswordPopView: PasswordInputCompleteProtocol {
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
        
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasswordPopView {
    func validation(_ input: String) -> Bool {
        return input == UserConfigure.shared.password.value
    }
    
    func validationSuccess() {
        successAction?()
        SwiftEntryKit.dismiss()
    }
    
    func validationFail() {
        passwordContainerView.wrongPassword()
    }
}
