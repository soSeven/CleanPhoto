//
//  UserModel.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/15.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

class UserModel: NSObject, Mapable, NSCoding {
    
    var id : String!
    var token : String!
    var isNew : Bool!
    var channel: String!
    var vipDateTime: String!
    var isVip: Bool!
    var tokenStatus: Int!
    
    required init(json: JSON) {
        
        id = json["id"].stringValue
        token = json["token"].stringValue
        isNew = json["is_new"].boolValue
        channel = json["channel"].stringValue
        vipDateTime = json["vip_expire_time"].stringValue
        isVip = json["vip_level"].boolValue
        tokenStatus = json["token_status"].intValue
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(channel, forKey: "channel")
        coder.encode(vipDateTime, forKey: "vip_expire_datetime")
        coder.encode(isVip, forKey: "vip_level")
        coder.encode(token, forKey: "token")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "id") as? String
        isVip = coder.decodeObject(forKey: "vip_level") as? Bool
        channel = coder.decodeObject(forKey: "channel") as? String
        vipDateTime = coder.decodeObject(forKey: "vip_expire_datetime") as? String
        token = coder.decodeObject(forKey: "token") as? String
    }
    
}



