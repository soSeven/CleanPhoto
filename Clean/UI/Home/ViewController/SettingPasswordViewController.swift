//
//  SettingPasswordViewController.swift
//  Clean
//
//  Created by liqi on 2020/11/2.
//

import UIKit

class SettingPasswordViewController: ViewController {
    
    enum PasswordType {
        case create
        case change
    }
    
    var passwordType: PasswordType = .create
    
    private var passwordContainerView: PasswordContainerView!
    private let kPasswordDigit = 4
    private var createPassword: String?
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#333333")
        lbl.font = .init(style: .medium, size: 16.uiX)
        lbl.text = "创建密码"
        return lbl
    }()
    
    lazy var errorLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hex: "#FE3838")
        lbl.font = .init(style: .regular, size: 13.uiX)
        lbl.text = "密码不一致"
        return lbl
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        navigationItem.title = "设置"
        
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40.uiX)
            make.centerX.equalToSuperview()
        }
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20.uiX

        stackView.addArrangedSubview(titleLbl)
        stackView.addArrangedSubview(errorLbl)
        
        errorLbl.isHidden = true
        
        passwordContainerView = PasswordContainerView.create(in: stackView, digit: kPasswordDigit)
        passwordContainerView.touchAuthenticationEnabled = false
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "删除"
    }
    
}

extension SettingPasswordViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
        if createPassword == nil {
            createPassword = input
            titleLbl.text = "确认密码"
            passwordContainerView.clearInput()
        } else {
            if validation(input) {
                validationSuccess()
            } else {
                validationFail()
            }
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
//        if success {
//            self.validationSuccess()
//        } else {
//            passwordContainerView.clearInput()
//        }
    }
}

private extension SettingPasswordViewController {
    func validation(_ input: String) -> Bool {
        return input == createPassword
    }
    
    func validationSuccess() {
        UserConfigure.shared.password.accept(createPassword)
        navigationController?.popViewController(animated: true)
    }
    
    func validationFail() {
        errorLbl.isHidden = false
        passwordContainerView.wrongPassword()
    }
}
