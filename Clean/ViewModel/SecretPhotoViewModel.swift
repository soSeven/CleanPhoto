//
//  SecretPhotoViewModel.swift
//  Clean
//
//  Created by liqi on 2020/10/30.
//

import RxCocoa
import RxSwift

class SecretPhotoViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let addItems: Observable<[PhotoModel]>
        let deleteItems: Observable<[PhotoModel]>
    }
    
    struct Output {
        let items: BehaviorRelay<[PhotoModel]>
        let addProgress: PublishRelay<((Float, Bool))>
        let endProgress: PublishRelay<[PhotoModel]>
        let showEmpty: BehaviorRelay<Bool>
        
    }
    
    func transform(input: Input) -> Output {
        
        let showEmpty = BehaviorRelay<Bool>(value: false)
        let items = BehaviorRelay<[PhotoModel]>(value: [])
        items.subscribe(onNext: { m in
            showEmpty.accept(m.isEmpty)
        }).disposed(by: rx.disposeBag)
        ExportPhotoHelper.shared.loadLocalPhotos().trackActivity(loading).trackError(error).subscribe(onNext: { models in
            items.accept(models)
        }).disposed(by: rx.disposeBag)
        
        let addProgress = PublishRelay<((Float, Bool))>()
        let endProgress = PublishRelay<[PhotoModel]>()
        input.addItems.subscribe(onNext: { addItems in
            if addItems.isEmpty {
                return
            }
            addProgress.accept((0, false))
            ExportPhotoHelper.shared.export(for: addItems, progress: { p in
                DispatchQueue.main.async {
                    addProgress.accept((p, false))
                }
            }, completion: { photos in
                var lastItems = items.value
                lastItems.insert(contentsOf: photos.reversed(), at: 0)
                items.accept(lastItems)
                addProgress.accept((1, true))
                endProgress.accept(addItems)
            })
            
        }).disposed(by: rx.disposeBag)
        
        input.deleteItems.subscribe(onNext: { deleteItems in
            if deleteItems.isEmpty {
                return
            }
            if deleteItems.count == 1 {
                ExportPhotoHelper.shared.deleteLocalPhoto(deleteItems.first!)
                var lastItems = items.value
                lastItems.removeAll(deleteItems)
                items.accept(lastItems)
                return
            }
            
            addProgress.accept((0, false))
            ExportPhotoHelper.shared.deleteLocalPhotos(for: deleteItems, progress: { p in
                DispatchQueue.main.async {
                    addProgress.accept((p, false))
                }
            }, completion: {
                var lastItems = items.value
                lastItems.removeAll(deleteItems)
                items.accept(lastItems)
                addProgress.accept((1, true))
            })
            
        }).disposed(by: rx.disposeBag)
        
        return Output(items: items, addProgress: addProgress, endProgress: endProgress, showEmpty: showEmpty)
    }
    
}
