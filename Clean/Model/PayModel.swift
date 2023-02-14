//
//  PayModel.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/4.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import SwiftyJSON

class PayProductModel: Mapable {
    
    var name : String!
    var price : String!
    var description : String!
    var id : String!
    var isRecommend : Bool!
    
    required init(json: JSON) {
        
        name = json["desc_days"].stringValue
        price = json["price"].stringValue
        description = json["desc"].stringValue
        id = json["product_id"].stringValue
        isRecommend = json["is_recommend"].boolValue
       
    }
    
}
