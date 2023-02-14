//
//  LaunchViewController.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/8/14.
//  Copyright © 2020 LQ. All rights reserved.
//

import UIKit
import SwiftEntryKit
import RxSwift

class LaunchViewController: ViewController {
    
    var completion: (()->())?
    private var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let launchView = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen").view {
            view.addSubview(launchView)
            launchView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        login()
    }
    
    private func login() {
        SwiftEntryKit.dismiss()
        self.loading = true
        UserManager.shared.loginUser().subscribe(onSuccess: {[weak self] in
            guard let self = self else { return }
            self.loading = false
            self.completion?()
        }, onError: { _ in
            self.loading = false
            let message = MessageAlert()
            let title = "温馨提示"
            let text = "请求网络失败，请检查网络是否连接"
            message.titleLbl.text = title
            message.msgLbl.text = text
            message.show()
            message.leftBtn.rx.tap.subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                self.login()
            }).disposed(by: self.rx.disposeBag)
            message.rightBtn.rx.tap.subscribe(onNext: { _ in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
    }
    
}

