//
//  HomeTypeModel.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import Foundation

enum HomeType {
    case photos
    case users
    case secret
    
    var imgName: String {
        switch self {
        case .photos:
            return "zpspgl-icon"
        case .users:
            return "txlgl-icon"
        case .secret:
            return "smkj-icon"
        }
    }
    
    var title: String {
        switch self {
        case .photos:
            return "照片视频管理"
        case .users:
            return "通讯录管理"
        case .secret:
            return "私密空间"
        }
    }
    
    var content: String {
        switch self {
        case .photos:
            return "屏幕截图、相似照片、相似视频、类似动态图、连拍照片"
        case .users:
            return "重复、名称为空、号码为空、备份/还原"
        case .secret:
            return "导入私密照片，视频，通讯录联系人"
        }
    }
}


