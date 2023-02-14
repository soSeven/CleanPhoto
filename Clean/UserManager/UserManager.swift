//
//  UserManager.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/15.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum UserLoginType {
    case phone(mobile: String, code: String)
    case aliAu(token: String)
    case wechat(openId: String, nickName: String, avatar: String, sex: Int)
    case apple(openId: String, nickName: String)
}

enum LoginStatus: Int {
    case notLogin
    case login
    case change
    case loginOut
}

class UserManager: NSObject {
    
    static let shared = UserManager()
    
    let login = BehaviorRelay<(UserModel?, LoginStatus)>(value: (nil, .notLogin))
    
    private let loading = ActivityIndicator()
    
    private let parsedError = PublishSubject<NetError>()
    private let error = ErrorTracker()
    
    private let onView = UIApplication.shared.keyWindow
    
    private let userPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + "/userinfo"
    
    var isLogin: Bool {
        let s = login.value
        return s.1 != .loginOut && s.1 != .notLogin
    }
    
    var user: UserModel? {
        return login.value.0
    }
    
    override init() {
        super.init()
        
        let user = NSKeyedUnarchiver.unarchiveObject(withFile: self.userPath) as? UserModel
        if let user = user {
            let date = Date().timeIntervalSince1970
            var vip = 0.0
            if let vipTime = user.vipDateTime {
                vip = vipTime.double() ?? 0.0
            }
            if date >= vip {
                user.isVip = false
            }
            login.accept((user, .login))
        }
        setupBinding()
    }
    
    private func setupBinding() {
        
        if let view = onView {
            error.asObservable().map { (error) -> NetError? in
                print(error)
                if let e = error as? NetError {
                    return e
                }
                return NetError.error(code: -1111, msg: error.localizedDescription)
            }.filterNil().bind(to: view.rx.toastError).disposed(by: rx.disposeBag)

            loading.asObservable().bind(to: view.rx.mbHudLoaing).disposed(by: rx.disposeBag)
        }

        login.subscribe(onNext: {[weak self] user in
            guard let self = self else { return }
            if let u = user.0 {
                NSKeyedArchiver.archiveRootObject(u, toFile: self.userPath)
            } else {
                try? FileManager.default.removeItem(atPath: self.userPath)
            }
        }).disposed(by: rx.disposeBag)

    }
    
    
    // MARK: - Login
    
    func updateUser() {
        if isLogin {
            let update = NetManager.requestObj(.updateUser, type: UserModel.self)
            update.asObservable().subscribe(onNext: {[weak self] newUser in
                guard let self = self else { return }
                if let currentUser = self.login.value.0, let newUser = newUser {
                    if newUser.tokenStatus == 0 {
                        self.login.accept((nil, .loginOut))
                    } else {
                        currentUser.vipDateTime = newUser.vipDateTime
                        currentUser.isVip = newUser.isVip
                        self.login.accept((currentUser, .change))
                    }
                }
            }, onError: { error in

            }).disposed(by: rx.disposeBag)
        }
    }
    
    // MARK: - Login
    
    func loginUser() -> Single<Void> {
        
        return Single<Void>.create { single in
            
            let login = NetManager.requestObj(.login, type: UserModel.self)
            login.asObservable().trackActivity(self.loading).trackError(self.error).subscribe(onNext: { user in
                self.login.accept((user, .login))
                single(.success(()))
            }, onError: { error in
                single(.error(error))
            }).disposed(by: self.rx.disposeBag)
            
            return Disposables.create()
        }
    }
    
}

