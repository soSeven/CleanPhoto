//
//  HomeViewModel.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import RxCocoa
import RxSwift

class HomeViewModel: ViewModel, ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        let items: BehaviorRelay<[HomeType]>
    }
    
    func transform(input: Input) -> Output {
        
        let items = BehaviorRelay<[HomeType]>(value: [
            .photos,
//            .users,
            .secret,
        ])
        
        return Output(items: items)
    }
    
}
