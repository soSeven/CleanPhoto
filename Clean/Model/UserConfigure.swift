//
//  UserConfigure.swift
//  Clean
//
//  Created by liqi on 2020/11/2.
//

import RxSwift
import RxCocoa

class UserConfigure: NSObject {
    
    static let shared = UserConfigure()
    
    /// 密码存储
    let password: BehaviorRelay<String?>
    /// touchId FaceId
    let isTouchId: BehaviorRelay<Bool>
    /// 是否删除照片
    let isDeletePhoto: BehaviorRelay<Bool>
    /// 是否删除通讯录
    let isDeleteUsers: BehaviorRelay<Bool>
    
    override init() {
        
        let passKey = "passKey"
        let passV = UserDefaults.standard.object(forKey: passKey) as? String
        password = BehaviorRelay<String?>(value: passV)
        
        let photoKey = "photoKey"
        let photoV = UserDefaults.standard.object(forKey: photoKey) as? Bool ?? false
        isDeletePhoto = BehaviorRelay<Bool>(value: photoV)
        
        let usersKey = "usersKey"
        let usersV = UserDefaults.standard.object(forKey: usersKey) as? Bool ?? false
        isDeleteUsers = BehaviorRelay<Bool>(value: usersV)
        
        let touchIdKey = "touchIdKey"
        var touchIdV = UserDefaults.standard.object(forKey: touchIdKey) as? Bool ?? false
        if touchIdV {
           (touchIdV, _) = TouchIdManager.isCanUseTouchIdOrFaceId
        }
        isTouchId = BehaviorRelay<Bool>(value: touchIdV)
        
        super.init()
        
        password.subscribe(onNext: { n in
            UserDefaults.standard.setValue(n, forKey: passKey)
            if n == nil {
                self.isTouchId.accept(false)
            }
            MobClick.event("pass_word_import_on", attributes: [
                "type": n != nil ? "open" : "close"
            ])
        }).disposed(by: rx.disposeBag)
        
        isDeletePhoto.subscribe(onNext: { n in
            MobClick.event("photo_import_on", attributes: [
                "type": n ? "open" : "close"
            ])
            UserDefaults.standard.setValue(n, forKey: photoKey)
        }).disposed(by: rx.disposeBag)
        
        isDeleteUsers.subscribe(onNext: { n in
            UserDefaults.standard.setValue(n, forKey: usersKey)
        }).disposed(by: rx.disposeBag)
        
        isTouchId.subscribe(onNext: { n in
            MobClick.event("touch_id_import_on", attributes: [
                "type": n ? "open" : "close"
            ])
            UserDefaults.standard.setValue(n, forKey: touchIdKey)
        }).disposed(by: rx.disposeBag)
        
    }
    
    var isHasPassword: Bool {
        return password.value != nil
    }
    
    var isHasTouchId: Bool {
        return isTouchId.value
    }
}
