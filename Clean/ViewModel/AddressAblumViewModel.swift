//
//  AddressAblumViewModel.swift
//  Clean
//
//  Created by liqi on 2020/11/4.
//

import RxCocoa
import RxSwift
import CoreLocation

class AddressAblumViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let request: Observable<[PhotoModel]>
    }
    
    struct Output {
        let items: BehaviorRelay<[[PhotoModel]]>
    }
    
    func transform(input: Input) -> Output {
        
        let items = BehaviorRelay<[[PhotoModel]]>(value: [])
        
        input.request.subscribe(onNext: {[weak self] photos in
            guard let self = self else { return }
            self.requestAddress(photos: photos).trackError(self.error).trackActivity(self.loading).subscribe(onNext: { group in
                items.accept(group)
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        return Output(items: items)
    }

    // MARK: - Request Address
    
    private func requestAddress(photos: [PhotoModel]) -> Single<[[PhotoModel]]> {
        
        return Single<[[PhotoModel]]>.create { single -> Disposable in
            DispatchQueue.global(qos: .userInitiated).async {
                let sem = DispatchSemaphore(value: 0)
                let der = CLGeocoder()
                var mPhotoLocations = photos
                var groupLocations = [[PhotoModel]]()
                while mPhotoLocations.count > 0 {
                    let g1 = mPhotoLocations.filter { p -> Bool in
                        return p.asset.location!.distance(from: mPhotoLocations.first!.asset.location!) <= 80000
                    }
                    groupLocations.append(g1)
                    mPhotoLocations.removeAll(g1)
                }

                for photos in groupLocations {
                    let photo = photos.first!
                    if photo.address == nil {
                        if let address = AddressDbManager.shared.select(identifier: photo.asset.localIdentifier) {
                            photo.address = address
                        } else  {
                            print("\(photo.asset.location!.coordinate.latitude),\(photo.asset.location!.coordinate.longitude)")
                            der.cancelGeocode()
                            der.reverseGeocodeLocation(photo.asset.location!) { (marks, error) in
                                photo.address = marks?.first?.locality
                                if let address = photo.address {
                                    photos.forEach { m in
                                        m.address = address
                                        AddressDbManager.shared.add(address: address, identifier: m.asset.localIdentifier)
                                    }
                                }
                                sem.signal()
                            }
                            sem.wait()
                        }
                    }
                }
                
                var group = [[PhotoModel]]()
                while groupLocations.count > 0 {
                    let g1 = groupLocations.filter { p -> Bool in
                        return p.first?.address == groupLocations.first?.first?.address
                    }
                    let total = g1.reduce([], {$0 + $1})
                    group.append(total)
                    groupLocations.removeAll(g1)
                }
                
                DispatchQueue.main.async {
                    single(.success(group))
                }
            }
            return Disposables.create()
        }
    }
    
}
