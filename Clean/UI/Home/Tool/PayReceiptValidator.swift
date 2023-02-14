//
//  PayReceiptValidator.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/4.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import RxSwift
import RxCocoa
import SwiftyJSON


public struct PayReceiptValidator: ReceiptValidator {
    
    let disposeBag = DisposeBag()

    public func validate(receiptData: Data, completion: @escaping (VerifyReceiptResult) -> Void) {

        let receipt = receiptData.base64EncodedString(options: [])
        NetProvider.request(.pay(receipt: receipt)) { result in
            switch result {
            case let .success(response):
                let dataOptional = try? response.mapJSON()
                guard let data = dataOptional else {
                    completion(.error(error: .networkError(error:  NetError.error(code: NetManager.NotJsonCode, msg: "解析错误"))))
                    return
                }
                let json = JSON(data)
                let ybResponse = Response(code: json["code"].intValue, data: json["data"], msg: json["message"].stringValue)
                switch ybResponse.code {
                case NetManager.SuccessCode:
                    completion(.success(receipt: [:]))
                default:
                    completion(.error(error: .networkError(error: NetError.error(code: ybResponse.code, msg: ybResponse.msg))))
                }
            case let .failure(error):
                completion(.error(error: .networkError(error: error)))
            }
        }
//        NetManager.requestResponse(.pay(receipt: receipt)).debug().subscribe(onSuccess: { _ in
//
//        }) { error in
//            completion(.error(error: .networkError(error: error)))
//        }.disposed(by: disposeBag)
        
    }
}
