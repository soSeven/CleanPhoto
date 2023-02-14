//
//  SettingViewModel.swift
//  Clean
//
//  Created by liqi on 2020/11/2.
//

import RxCocoa
import RxSwift
import RxDataSources

class SettingViewModel: ViewModel, ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        let items: BehaviorRelay<[SectionModel<String, SettingTypeModel>]>
        let usePassword: PublishRelay<Void>
        let changeTouchId: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let itemsRelay = BehaviorRelay<[SectionModel<String, SettingTypeModel>]>(value: [])
        let usePasswordRelay = PublishRelay<Void>()
        let changeTouchIdRelay = PublishRelay<Void>()
        
        UserConfigure.shared.password.subscribe(onNext: { [weak self] password in
            guard let self = self else { return }
            
            let photo = SettingTypeModel(type: .photo, title: "照片和视频", img: "zpsp-icon")
            UserConfigure.shared.isDeletePhoto.bind(to: photo.selectedRelay).disposed(by: self.rx.disposeBag)
            photo.selectedEvent.subscribe(onNext: { model in
                UserConfigure.shared.isDeletePhoto.accept(!UserConfigure.shared.isDeletePhoto.value)
            }).disposed(by: self.rx.disposeBag)
            let section1 = SectionModel<String, SettingTypeModel>(model: "1", items: [
                photo
            ])
            
            let usePassword = SettingTypeModel(type: .usePassword, title: "使用密码", img: "symm-icon")
            usePassword.selectedRelay.accept(password != nil)
            usePassword.selectedEvent.subscribe(onNext: { model in
                usePasswordRelay.accept(())
            }).disposed(by: self.rx.disposeBag)
            
            let (_, context) = TouchIdManager.isCanUseTouchIdOrFaceId
            var isTouchID = true
            if #available(iOS 11.0, *) {
                if context.biometryType == .faceID {
                    isTouchID = false
                }
            }
            let touchId = SettingTypeModel(type: .touchId, title: isTouchID ? "使用 Touch ID" : "使用Face ID", img: "syid-icon")
            UserConfigure.shared.isTouchId.bind(to: touchId.selectedRelay).disposed(by: self.rx.disposeBag)
            touchId.selectedEvent.subscribe(onNext: { model in
                changeTouchIdRelay.accept(())
            }).disposed(by: self.rx.disposeBag)
            
            var section2Items = [usePassword, touchId]
            if password != nil {
                let changePassword = SettingTypeModel(type: .changePassword, title: "更改密码", img: "ggmm-icon")
                section2Items.append(changePassword)
            }
            let section2 = SectionModel<String, SettingTypeModel>(model: "2", items: section2Items)
            
            let section3 = SectionModel<String, SettingTypeModel>(model: "3", items: [
                SettingTypeModel(type: .question, title: "常见问题解答", img: "symm-icon"),
                SettingTypeModel(type: .privacy, title: "隐私政策", img: "syid-icon"),
                SettingTypeModel(type: .userProtocol, title: "使用条例", img: "ggmm-icon"),
            ])
            
            itemsRelay.accept([section1, section2, section3])
        }).disposed(by: rx.disposeBag)
        
        return Output(items: itemsRelay, usePassword: usePasswordRelay, changeTouchId: changeTouchIdRelay)
    }
    
}
