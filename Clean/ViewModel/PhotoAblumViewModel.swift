//
//  PhotoAblumViewModel.swift
//  Clean
//
//  Created by liqi on 2020/10/29.
//

import RxCocoa
import RxSwift

class PhotoAblumViewModel: ViewModel, ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        let items: BehaviorRelay<[PhotoModel]>
        let selected: BehaviorRelay<[PhotoModel]>
    }
    
    func transform(input: Input) -> Output {
        
        let items = BehaviorRelay<[PhotoModel]>(value: [])
        var selectedModels = [PhotoModel]()
        let selected = BehaviorRelay<[PhotoModel]>(value: selectedModels)
        PhotoManager.shared.fetchUserLibrary().trackActivity(loading).trackError(error).subscribe(onNext: {[weak self] models in
            guard let self = self else { return }
            for m in models {
                m.selectedType.subscribe(onNext: { type in
                    switch type {
                    case .deselected:
                        selectedModels.removeAll(m)
                    case .selected:
                        if !selectedModels.contains(m) {
                            selectedModels.append(m)
                        }
                    }
                    selected.accept(selectedModels)
                }).disposed(by: self.rx.disposeBag)
            }
            items.accept(models)
        }).disposed(by: rx.disposeBag)
        
        return Output(items: items, selected: selected)
    }
    
}
