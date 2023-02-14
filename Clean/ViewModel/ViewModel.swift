//
//  ViewModel.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/9.
//  Copyright © 2020 Qire. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    
}

class ViewModel: NSObject {
    
    let loading = ActivityIndicator()
    
    let parsedError = PublishSubject<NetError>()
    let error = ErrorTracker()
    
    override init() {
        super.init()
        error.asObservable().map { (error) -> NetError? in
            if let e = error as? NetError {
                return e
            }
            print(error)
            if let e = error as? RxError {
                switch e {
                case .timeout:
                    return NetError.error(code: -1111, msg: "请求超时")
                default:
                    break
                }
            }
            return NetError.error(code: -1111, msg: error.localizedDescription)
        }.filterNil().bind(to: parsedError).disposed(by: rx.disposeBag)
    }
}
