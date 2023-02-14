//
//  ReachabilityManager.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/10.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class ReachabilityManager {
    
    static let shared = ReachabilityManager()
    
    let relay = BehaviorRelay<NetworkReachabilityManager.NetworkReachabilityStatus>(value: NetworkReachabilityManager.default!.status)
    
    init() {
        
        NetworkReachabilityManager.default!.startListening(onQueue: .main, onUpdatePerforming: { status in
            self.relay.accept(status)
        })
        
    }
    
    
}
