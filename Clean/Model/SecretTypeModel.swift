//
//  SecretTypeModel.swift
//  Clean
//
//  Created by liqi on 2020/10/29.
//

import UIKit

enum SecretType {
    case photos
    case users
    
    var imgName: String {
        switch self {
        case .photos:
            return "zpzj-bj"
        case .users:
            return "smtxl-bj"
        }
    }
    
    var title: String {
        switch self {
        case .photos:
            return "照片专辑"
        case .users:
            return "私密通讯录"
        }
    }
    
    var content: String {
        switch self {
        case .photos:
            return "我的私人照片和视频"
        case .users:
            return "我的私人通讯录"
        }
    }
    
    var contentColor: UIColor {
        switch self {
        case .photos:
            return .init(hex: "#C7E0FF")
        case .users:
            return .init(hex: "#C7F3D3")
        }
    }
}
