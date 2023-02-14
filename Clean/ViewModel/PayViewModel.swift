//
//  PayViewModel.swift
//  Clean
//
//  Created by liqi on 2020/11/10.
//

import Foundation
import RxCocoa
import RxSwift

class PayViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let request: Observable<Void>
        let buy: Observable<String>
        let restore: Observable<Void>
    }
    
    struct Output {
        let items: BehaviorRelay<[PayProductModel]>
        let buySuccess: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        
        let items = BehaviorRelay<[PayProductModel]>(value: [])
        let buySuccess = PublishRelay<String>()
        
        input.request.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.requestProduct().subscribe(onNext: { list in
                items.accept(list)
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        input.buy.subscribe(onNext: {[weak self] id in
            guard let self = self else { return }
            PayManager.shared.buyProduct(with: id).trackError(self.error).trackActivity(self.loading).subscribe(onNext: { _ in
                UserManager.shared.updateUser()
                buySuccess.accept("购买成功")
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        input.restore.subscribe(onNext: {_ in
            PayManager.shared.restore()
        }).disposed(by: rx.disposeBag)

        
        return Output(items: items, buySuccess: buySuccess)
    }
    
    /// MARK: - Request
    
    func requestProduct() -> Observable<[PayProductModel]> {

        return NetManager.requestObjArray(.paylist, type: PayProductModel.self).trackError(error).trackActivity(loading)
    }
    
}
