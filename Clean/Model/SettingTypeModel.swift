//
//  SettingTypeModel.swift
//  Clean
//
//  Created by liqi on 2020/11/2.
//

import RxSwift
import RxCocoa

class SettingTypeModel {
    
    enum SettingType {
        case photo
        case users
        case usePassword
        case touchId
        case changePassword
        case question
        case privacy
        case userProtocol
    }
    
    let title: String
    let img: String
    let selectedRelay = BehaviorRelay<Bool>(value: false)
    let selectedEvent = PublishRelay<SettingTypeModel>()
    let type: SettingType
    
    init(type: SettingType, title: String, img: String) {
        self.type = type
        self.title = title
        self.img = img
    }
    
}

