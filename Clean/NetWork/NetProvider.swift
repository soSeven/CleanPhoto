//
//  NetProvider.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/10.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import Moya
import FCUUID
import Alamofire
import FileKit
import Kingfisher
import SwifterSwift
import AdSupport

let NetProvider = MoyaProvider<NetAPI>(requestClosure: { (endpoint, done) in
    do {
        var request = try endpoint.urlRequest()
        request.timeoutInterval = 20//设置请求超时时间
        done(.success(request))
    } catch {

    }
})

public enum NetAPI {
    
    /// 用户登录
    case login
    /// 更新用户
    case updateUser
    /// 支付选项列表
    case paylist
    /// 支付
    case pay(receipt: String)
    
}

public enum NetHtmlAPI {
    
    /// 用户协议
    case userProtocol
    /// 隐私政策
    case privacy
    /// 常见问题
    case question
    
    var url: URL? {
        return URL(string: String(format: "%@%@", NetAPI.getBaseURL, path))
    }
    
    var path: String {
        switch self {
        case .userProtocol:
            return "api/article/view?id=1"
        case .privacy:
            return "api/article/view?id=2"
        case .question:
            return "api/fqa/index"
        }
    }
    
    
}

extension NetAPI: TargetType {
    
    static var getBaseURL: String {
        if AppDefine.isDebug {
            return "https://ios-cleaner-api.zhouyismb.com/"
        } else {
            return "https://cleaner-api.spshenqi.com/"
        }
        
    }
    
    public var baseURL: URL {
        let baseUrl = URL(string: NetAPI.getBaseURL)!
        return baseUrl
    }
    
    public var path: String {
        switch self {
        case .login:
            return "api/v1/login"
        case .paylist:
            return "api/v1/p-item/index"
        case .pay:
            return "api/v1/pay-apple/add"
        case .updateUser:
            return "api/v1/user/info"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var parameters: [String:Any]  {
        
        var params:[String:Any] = [:]
        if let id = UserManager.shared.login.value.0?.id {
            params["userid"] = id
        }
        if let token = UserManager.shared.login.value.0?.token {
            params["token"] = token
        }
        
        switch self {
        case .login:
            params["device_number"] = UIDevice.current.uuid()
        case let .pay(receipt):
            params["receipt"] = receipt
        default:
            break
        }
        return params
    }
    
    public var task: Task {
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    public var headers: [String : String]? {
        
        var headers:[String : String] = [:]
        
        headers["os"] = "1"
        headers["channel"] = UserManager.shared.login.value.0?.channel ?? "unknown"
        headers["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        headers["timestamp"] = Date().timeIntervalSince1970.string

        if let userid = UserManager.shared.login.value.0?.id {
            headers["userid"] = userid
        }
        
        if let token = UserManager.shared.login.value.0?.token {
            headers["token"] = token
        }
        
        switch self {
        case .login:
            headers["device-number"] = UIDevice.current.uuid()
        default:
            break
        }
        
        switch self {
        case .login:
            headers["sign"] = getSign(pa: headers)
        default:
            headers["sign"] = getSign(pa: headers + parameters)
        }
        
        return headers
    }
    
    private func getSign(pa: [String:Any]) -> String {
        let secretKey = AppDefine.isDebug ? "123456" : "PgUegY7mmWmC68kPaTOC1C6xNGffVpAI"
        let a = pa.sorted { (v1, v2) -> Bool in
            v1.key < v2.key
        }
        let s = a.map { (key, value) -> String in
            if let str = value as? String {
                return "\(key)=\(str.urlEncoded)"
            } else {
                return "\(key)=\(value)"
            }
        }.joined(separator: "&") + "&key=\(secretKey)"
        let md5 = s.md5.uppercased()
        return md5
    }
}

