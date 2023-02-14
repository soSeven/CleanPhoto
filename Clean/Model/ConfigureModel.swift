//
//  ConfigureModel.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/8/14.
//  Copyright © 2020 LQ. All rights reserved.
//

import Foundation
import SwiftyJSON

class ConfigureModel: Mapable {
    
    var const : ConfigureConstModel!
    var hp : ConfigureHpModel!
    var musicType : [ConfigureMusicTypeModel]!
    var page : ConfigurePageModel!
    var single : ConfigureSingleModel!
    var songAd: ConfigureSongAdModel!
    var cashs: [ConfigurePriceModel]!
    var staticDomain: String

    required init(json: JSON) {

        const = ConfigureConstModel(json: json["const"])
        hp = ConfigureHpModel(json: json["hp"])
        musicType = json["music_type"].arrayValue.map{ ConfigureMusicTypeModel(json: $0) }
        page = ConfigurePageModel(json: json["page"])
        single = ConfigureSingleModel(json: json["single"])
        songAd = ConfigureSongAdModel(json: json["song_ad"])
        cashs = json["withdraw_config"].arrayValue.map{ConfigurePriceModel(json: $0)}
        staticDomain = json["static_domain"].stringValue
    }

}

class ConfigureSingleModel: Mapable {
    
    var adRestoreNum : Int!
    var max : Int!
    
    required init(json: JSON) {
        adRestoreNum = json["ad_restore_num"].intValue
        max = json["max"].intValue
    }

}

class ConfigurePageModel: Mapable {
    
    var privacyPolicy : String!
    var settlementAgreement : String!
    var userAgreement : String!
    var userLogoutAgreement : String!
    
    required init(json: JSON) {
        privacyPolicy = json["privacy_policy"].stringValue
        settlementAgreement = json["settlement_agreement"].stringValue
        userAgreement = json["user_agreement"].stringValue
        userLogoutAgreement = json["user_logout_agreement"].stringValue
    }
    
}

class ConfigureMusicTypeModel: Mapable {
    
    var id : Int!
    var key : String!
    var name : String!
    
    required init(json: JSON) {
        id = json["id"].intValue
        key = json["key"].stringValue
        name = json["name"].stringValue
    }

}

class ConfigureHpModel: Mapable {

    var adRestoreNum : Int!
    var start : Int!
    var max : Int!
    var restoreNum : Int!
    var restoreTime : Int!
    
    required init(json: JSON) {
        adRestoreNum = json["ad_restore_num"].intValue
        start = json["init"].intValue
        max = json["max"].intValue
        restoreNum = json["restore_num"].intValue
        restoreTime = json["restore_time"].intValue
    }

}

class ConfigureConstModel: Mapable {
    
    var guessSongMasonry : Int!
    var signCashNum : Int!
    var songCashLevel : Int!
    var timerCashTime : Int!
    var remandiOS : Int!
    var adDance: Int!
    var adQQ: Int!

    required init(json: JSON) {
        guessSongMasonry = json["guess_song_masonry"].intValue
        signCashNum = json["sign_cash_num"].intValue
        songCashLevel = json["song_cash_level"].intValue
        timerCashTime = json["timer_cash_time"].intValue
        remandiOS = json["remand_ios"].intValue
        adDance = json["ios_ad_oceanengine_num"].intValue
        adQQ = json["ios_ad_qq_num"].intValue
    }
    
}

class ConfigureSongAdModel: Mapable {
    
    var convertGold : Int!
    var convertMax : Int!
    var levelError : Int!
    var expirationTime: Int!

    required init(json: JSON) {
        convertGold = json["convert_gold"].intValue
        convertMax = json["convert_max"].intValue
        levelError = json["level_error"].intValue
        expirationTime = json["expiration_time"].intValue
    }
    
}

class ConfigurePriceModel: Mapable {
    
    var text: String!
    var cash : Int!
    var level : Int!
    var type: Int!

    required init(json: JSON) {
        type = json["type"].intValue
        level = json["level"].intValue
        cash = json["cash"].intValue
        text = json["text"].stringValue
    }
    
}
