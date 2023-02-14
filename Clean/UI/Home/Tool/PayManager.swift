//
//  PayManager.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/4.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import RxCocoa
import RxSwift

class PayManager {
    
    static let shared = PayManager()
    
    let loading = ActivityIndicator()
    
    let parsedError = PublishSubject<NetError>()
    let error = ErrorTracker()
    
    let disposeBag = DisposeBag()
    
    private var appleValidator: PayReceiptValidator?
    
    private let onView = UIApplication.shared.keyWindow
    
    init() {
        
        if let view = onView {
            error.asObservable().map { (error) -> NetError? in
                print(error)
                if let e = error as? NetError {
                    return e
                }
                return NetError.error(code: -1111, msg: error.localizedDescription)
            }.filterNil().bind(to: parsedError).disposed(by: disposeBag)
            parsedError.bind(to: view.rx.toastError).disposed(by: disposeBag)
            loading.asObservable().bind(to: view.rx.mbHudLoaing).disposed(by: disposeBag)
        }
        
    }
    
    
    func completeTransactionsWhenAppStart() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.check()
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
        
    }
    
    func restore() {
        
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.parsedError.onNext(NetError.error(code: 900013, msg: "恢复购买失败"))
            }
            else if results.restoredPurchases.count > 0 {
                
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.check()
                }
            }
            else {
                self.parsedError.onNext(NetError.error(code: 900013, msg: "没有恢复内容"))
            }
        }
    }
    
    func buyProduct(with id: String) -> Single<Void> {
        
        return purchaseProduct(with: id).flatMap { _ in
            return self.checkReceipt()
        }
        
    }
    
    private func check() {
        
        if !UserManager.shared.isLogin {
            return
        }
        
        self.checkReceipt().trackActivity(self.loading).trackError(self.error).subscribe(onNext: { _ in
            UserManager.shared.updateUser()
        }).disposed(by: self.disposeBag)
        
    }
    
    // 上传服务器 验证
    
    private func checkReceipt() -> Single<Void> {

        return Single.create { single in
            
            let appleValidator = PayReceiptValidator()
//            self.appleValidator = appleValidator
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                
                switch result {
                case .success:
                    single(.success(()))
                case let .error(error: error):
                    switch error {
                    case let .networkError(error: netError):
                        if let net = netError as? NetError {
                            single(.error(net))
                        } else {
                            single(.error(NetError.error(code: 90001, msg: "验证失败")))
                        }
                    default:
                        single(.error(NetError.error(code: 90001, msg: "验证失败")))
                    }
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    private func purchaseProduct(with id: String) -> Single<Void> {
        
        return Single<Void>.create { single in
            
            SwiftyStoreKit.retrieveProductsInfo([id]) { result in
                if let product = result.retrievedProducts.first {
                    SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                        switch result {
                        case .success(let product):
                            // fetch content from your server, then:
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }
                            
                            single(.success(()))
                            
                        case .error(let error):
                            switch error.code {
                            case .unknown:
                                single(.error(NetError.error(code: 90002, msg: "未知错误")))
                            case .clientInvalid:
                                single(.error(NetError.error(code: 90003, msg: "不支持付款")))
                            case .paymentCancelled:
                                single(.error(NetError.error(code: 90004, msg: "取消付款")))
                            case .paymentInvalid:
                                single(.error(NetError.error(code: 90005, msg: "支付ID无效")))
                            case .paymentNotAllowed:
                                single(.error(NetError.error(code: 90006, msg: "不支持付款")))
                            case .storeProductNotAvailable:
                                single(.error(NetError.error(code: 90007, msg: "该产品在当前店面中不可用")))
                            case .cloudServicePermissionDenied:
                                single(.error(NetError.error(code: 90008, msg: "不允许访问云服务信息")))
                            case .cloudServiceNetworkConnectionFailed:
                                single(.error(NetError.error(code: 90009, msg: "无法连接到网络")))
                            case .cloudServiceRevoked:
                                single(.error(NetError.error(code: 900010, msg: "用户已撤消使用此云服务的权限")))
                            default:
                                single(.error(NetError.error(code: 900011, msg: (error as NSError).localizedDescription)))
                            }
                        }
                    }
                } else {
                    single(.error(NetError.error(code: 900012, msg: "产品不存在")))
                }
            }
            
            return Disposables.create()
        }
        
    }
    
}
